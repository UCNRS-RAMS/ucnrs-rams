# frozen_string_literal: true

require "csv"

module Ops
  class InstitutionRorDeduplicator
    Group = Struct.new(:ror_id, :keep_id, :duplicate_ids, :set_ror_id, keyword_init: true)
    Result = Struct.new(:groups, :updated_references, :deleted_count, keyword_init: true)

    REQUIRED_HEADERS = %w[rams_id ror_id ror_match_type].freeze

    def initialize(csv_path)
      @csv_path = csv_path
    end

    def call(apply: false)
      rows = read_csv

      ActiveRecord::Base.connection_pool.with_connection do |connection|
        staging_table = "institution_ror_import_#{SecureRandom.hex(6)}"
        quoted_table = connection.quote_table_name(staging_table)

        begin
          create_staging_table(connection, staging_table)
          import_rows(connection, quoted_table, rows)

          Institution.transaction do
            groups = build_groups(connection, quoted_table)
            validate_existing_ror_ids!(groups)

            if apply
              updated_references, deleted_count = apply_groups(connection, groups)
            else
              updated_references = {}
              deleted_count = 0
            end

            Result.new(
              groups: groups,
              updated_references: updated_references,
              deleted_count: deleted_count
            )
          end
        ensure
          connection.execute("DROP TEMPORARY TABLE IF EXISTS #{quoted_table}")
        end
      end
    end

    private

    def read_csv
      table = CSV.read(@csv_path, headers: true, header_converters: :symbol, encoding: "bom|utf-8")
      headers = table.headers.compact.map(&:to_s)
      missing_headers = REQUIRED_HEADERS - headers
      raise ArgumentError, "CSV is missing required headers: #{missing_headers.join(', ')}" if missing_headers.any?

      rows = table.filter_map do |row|
        next if row.fields.all?(&:blank?)

        rams_id = row[:rams_id].to_s.strip
        ror_id = row[:ror_id].to_s.strip.presence
        match_type = row[:ror_match_type].to_s.strip.downcase

        unless rams_id.match?(/\A[1-9]\d*\z/)
          raise ArgumentError, "Invalid rams_id '#{row[:rams_id]}' in CSV."
        end
        raise ArgumentError, "Missing ror_match_type for institution #{rams_id}." if match_type.blank?
        if match_type == "direct" && ror_id.blank?
          raise ArgumentError, "Missing ror_id for direct institution #{rams_id}."
        end

        { rams_id: rams_id.to_i, ror_id: ror_id, ror_match_type: match_type }
      end

      raise ArgumentError, "CSV contains no data rows." if rows.empty?

      direct_mappings = rows.select { |row| row[:ror_match_type] == "direct" }.group_by { |row| row[:rams_id] }
      conflicting_mappings = direct_mappings.select { |_rams_id, mappings| mappings.map { |row| row[:ror_id] }.uniq.many? }
      if conflicting_mappings.any?
        ids = conflicting_mappings.keys.join(", ")
        raise ArgumentError, "Direct CSV rows map institution IDs to multiple ROR IDs: #{ids}."
      end

      rows
    end

    def create_staging_table(connection, table_name)
      connection.create_table(table_name, temporary: true, id: false) do |table|
        table.integer :rams_id, null: false
        table.string :ror_id
        table.string :ror_match_type, null: false
      end
    end

    def import_rows(connection, quoted_table, rows)
      rows.each_slice(500) do |batch|
        values = batch.map do |row|
          "(#{row.values_at(:rams_id, :ror_id, :ror_match_type).map { |value| connection.quote(value) }.join(', ')})"
        end

        connection.execute(
          "INSERT INTO #{quoted_table} (rams_id, ror_id, ror_match_type) VALUES #{values.join(', ')}"
        )
      end
    end

    def build_groups(connection, quoted_table)
      missing_ids = connection.select_values(<<~SQL)
        SELECT DISTINCT imported.rams_id
        FROM #{quoted_table} AS imported
        LEFT JOIN institutions ON institutions.id = imported.rams_id
        WHERE imported.ror_match_type = 'direct'
          AND institutions.id IS NULL
      SQL
      if missing_ids.any?
        raise ArgumentError, "Direct CSV institution IDs not found in institutions: #{missing_ids.join(', ')}."
      end

      matched = connection.select_all(<<~SQL).to_a
        SELECT DISTINCT institutions.id AS institution_id, imported.ror_id, institutions.ror_id AS current_ror_id
        FROM #{quoted_table} AS imported
        INNER JOIN institutions ON institutions.id = imported.rams_id
        WHERE imported.ror_match_type = 'direct'
        ORDER BY imported.ror_id, institutions.id
      SQL
      raise ArgumentError, "CSV contains no direct institution rows." if matched.empty?

      matched.group_by { |row| row.fetch("ror_id") }.map do |ror_id, rows|
        ids = rows.map { |row| row.fetch("institution_id").to_i }.uniq.sort
        Group.new(
          ror_id: ror_id,
          keep_id: ids.first,
          duplicate_ids: ids.drop(1),
          set_ror_id: rows.find { |row| row.fetch("institution_id").to_i == ids.first }
                          .fetch("current_ror_id").blank?
        )
      end
    end

    def validate_existing_ror_ids!(groups)
      ids = groups.flat_map { |group| [ group.keep_id, *group.duplicate_ids ] }
      existing = Institution.where(id: ids).pluck(:id, :ror_id).to_h

      groups.each do |group|
        [ group.keep_id, *group.duplicate_ids ].each do |institution_id|
          current_ror_id = existing.fetch(institution_id)
          next if current_ror_id.blank? || current_ror_id == group.ror_id

          raise ArgumentError,
                "Institution #{institution_id} already has ROR ID #{current_ror_id}, not #{group.ror_id}."
        end
      end
    end

    def apply_groups(connection, groups)
      reference_columns = institution_reference_columns(connection)
      updated_references = Hash.new(0)
      deleted_count = 0

      groups.each do |group|
        if group.set_ror_id
          Institution.find(group.keep_id).update!(ror_id: group.ror_id)
        end

        group.duplicate_ids.each do |duplicate_id|
          reference_columns.each do |table_name, column_name|
            updated_references[table_name] += update_reference(
              connection, table_name, column_name, duplicate_id, group.keep_id
            )
          end

          deleted = Institution.where(id: duplicate_id).delete_all
          raise "Institution #{duplicate_id} was not deleted." unless deleted == 1

          deleted_count += deleted
        end
      end

      [ updated_references, deleted_count ]
    end

    def institution_reference_columns(connection)
      references = connection.tables.flat_map do |table_name|
        connection.columns(table_name).filter_map do |column|
          [ table_name, column.name ] if column.name == "institution_id"
        end
      end

      if connection.columns(:institutions).any? { |column| column.name == "managing_institution_id" }
        references << [ "institutions", "managing_institution_id" ]
      end

      references
    end

    def update_reference(connection, table_name, column_name, old_id, new_id)
      quoted_table = connection.quote_table_name(table_name)
      quoted_column = connection.quote_column_name(column_name)

      connection.update(<<~SQL)
        UPDATE #{quoted_table}
        SET #{quoted_column} = #{connection.quote(new_id)}
        WHERE #{quoted_column} = #{connection.quote(old_id)}
      SQL
    end
  end
end
