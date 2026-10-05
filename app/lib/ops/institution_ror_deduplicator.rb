# frozen_string_literal: true

require "csv"
require "digest"
require "json"

module Ops
  class InstitutionRorDeduplicator
    Group = Struct.new(:ror_id, :keep_id, :duplicate_ids, :set_ror_id, keyword_init: true)
    Result = Struct.new(:groups, :updated_references, :deleted_count, :audit_run_id, keyword_init: true)

    # headers are from the Danny CSV file from google sheets which is expected to have this header row
    # rams_id,rams_name,rams_acronym,rams_city,ror_id,ror_name,ror_match_type but only the items below are used
    REQUIRED_HEADERS = %w[rams_id ror_id ror_match_type].freeze

    def initialize(csv_path)
      @csv_path = csv_path
      @audit_run_id = SecureRandom.uuid
    end

    def call(apply: false)
      with_staging_table(read_csv) do |connection, quoted_table|
        groups = build_groups(connection, quoted_table)
        validate_existing_ror_ids!(groups)

        Institution.transaction do
          build_result(groups, apply, connection)
        end
      end
    end

    private

    # creates a staging table for importing CSV into and so can join to obtain only the "direct" rows
    # which are the rows that are on the same level as the ROR institution (and not children or related institutions)
    def with_staging_table(rows)
      ActiveRecord::Base.connection_pool.with_connection do |connection|
        table_name = "institution_ror_import_#{SecureRandom.hex(6)}"
        quoted_table = connection.quote_table_name(table_name)

        begin
          # Keep CSV data available to SQL joins without retaining it after this one-off task exits.
          create_staging_table(connection, table_name)
          import_rows(connection, quoted_table, rows)
          yield connection, quoted_table
        ensure
          connection.execute("DROP TEMPORARY TABLE IF EXISTS #{quoted_table}")
        end
      end
    end

    def build_result(groups, apply, connection)
      updated_references, deleted_count = apply ? apply_groups(connection, groups) : [ {}, 0 ]

      Result.new(
        groups: groups,
        updated_references: updated_references,
        deleted_count: deleted_count,
        audit_run_id: apply ? @audit_run_id : nil
      )
    end

    def read_csv
      table = CSV.read(@csv_path, headers: true, header_converters: :symbol, encoding: "bom|utf-8")
      validate_headers!(table)

      rows = csv_rows(table)
      validate_rows!(rows)
      rows
    end

    def validate_headers!(table)
      missing_headers = REQUIRED_HEADERS - table.headers.compact.map(&:to_s)
      return if missing_headers.empty?

      raise ArgumentError, "CSV is missing required headers: #{missing_headers.join(', ')}"
    end

    def csv_rows(table)
      rows = table.filter_map { |row| parse_csv_row(row) }
      raise ArgumentError, "CSV contains no data rows." if rows.empty?

      rows
    end

    def parse_csv_row(row)
      return if row.fields.all?(&:blank?)

      rams_id = row[:rams_id].to_s.strip
      ror_id = row[:ror_id].to_s.strip.presence
      match_type = row[:ror_match_type].to_s.strip.downcase

      validate_row!(rams_id, ror_id, match_type, row)
      { rams_id: rams_id.to_i, ror_id: ror_id, ror_match_type: match_type }
    end

    def validate_row!(rams_id, ror_id, match_type, row)
      unless rams_id.match?(/\A[1-9]\d*\z/)
        raise ArgumentError, "Invalid rams_id '#{row[:rams_id]}' in CSV."
      end
      raise ArgumentError, "Missing ror_match_type for institution #{rams_id}." if match_type.blank?
      raise ArgumentError, "Missing ror_id for direct institution #{rams_id}." if match_type == "direct" && ror_id.blank?
    end

    # validates that a single rams_id is not marked as a "direct" match for multiple different ROR IDs in the CSV.
    def validate_rows!(rows)
      conflicting_ids = direct_mappings(rows).filter_map do |rams_id, mappings|
        rams_id if mappings.map { |row| row[:ror_id] }.uniq.many?
      end
      return if conflicting_ids.empty?

      raise ArgumentError, "Direct CSV rows map institution IDs to multiple ROR IDs: #{conflicting_ids.join(', ')}."
    end

    # only rows of type "direct" that may be used to merge institution, ignore others when validating CSV
    def direct_mappings(rows)
      rows.select { |row| row[:ror_match_type] == "direct" }.group_by { |row| row[:rams_id] }
    end

    # creates a staging table for importing CSV into and so can join to obtain only the "direct" rows
    def create_staging_table(connection, table_name)
      connection.create_table(table_name, temporary: true, id: false) do |table|
        table.integer :rams_id, null: false
        table.string :ror_id
        table.string :ror_match_type, null: false
      end
    end

    # import rows from CSV into table
    def import_rows(connection, quoted_table, rows)
      rows.each_slice(500) { |batch| insert_batch(connection, quoted_table, batch) }
    end

    # insert rows into table in batches to avoid exceeding max query length
    def insert_batch(connection, quoted_table, batch)
      values = batch.map { |row| quoted_row_values(connection, row) }
      connection.execute(
        "INSERT INTO #{quoted_table} (rams_id, ror_id, ror_match_type) VALUES #{values.join(', ')}"
      )
    end

    # quote values for SQL insertion
    def quoted_row_values(connection, row)
      values = row.values_at(:rams_id, :ror_id, :ror_match_type).map { |value| connection.quote(value) }
      "(#{values.join(', ')})"
    end

    # build groups of institutions based on their ROR IDs
    def build_groups(connection, quoted_table)
      validate_direct_institution_ids!(connection, quoted_table)

      matches = direct_matches(connection, quoted_table)
      raise ArgumentError, "CSV contains no direct institution rows." if matches.empty?

      matches.group_by { |row| row.fetch("ror_id") }.map { |ror_id, rows| build_group(ror_id, rows) }
    end

    # validate that all direct institution IDs in the CSV exist in the institutions table
    def validate_direct_institution_ids!(connection, quoted_table)
      missing_ids = connection.select_values(<<~SQL)
        SELECT DISTINCT imported.rams_id
        FROM #{quoted_table} AS imported
        LEFT JOIN institutions ON institutions.id = imported.rams_id
        WHERE imported.ror_match_type = 'direct'
          AND institutions.id IS NULL
      SQL
      return if missing_ids.empty?

      raise ArgumentError, "Direct CSV institution IDs not found in institutions: #{missing_ids.join(', ')}."
    end

    # find all direct matches between the CSV and the institutions table
    def direct_matches(connection, quoted_table)
      connection.select_all(<<~SQL).to_a
        SELECT DISTINCT institutions.id AS institution_id, imported.ror_id, institutions.ror_id AS current_ror_id
        FROM #{quoted_table} AS imported
        INNER JOIN institutions ON institutions.id = imported.rams_id
        WHERE imported.ror_match_type = 'direct'
        ORDER BY imported.ror_id, institutions.id
      SQL
    end

    # build a group of institutions that share the same ROR ID, keeping the one with the lowest ID and marking others as duplicates
    def build_group(ror_id, rows)
      ids = rows.map { |row| row.fetch("institution_id").to_i }.uniq.sort
      retained_row = rows.find { |row| row.fetch("institution_id").to_i == ids.first }

      Group.new(
        ror_id: ror_id,
        keep_id: ids.first,
        duplicate_ids: ids.drop(1),
        set_ror_id: retained_row.fetch("current_ror_id").blank?
      )
    end

    def validate_existing_ror_ids!(groups)
      existing_ror_ids = Institution.where(id: institution_ids(groups)).pluck(:id, :ror_id).to_h

      groups.each { |group| validate_group_ror_ids!(group, existing_ror_ids) }
    end

    # returns all institution IDs involved in the groups, both retained and duplicates
    def institution_ids(groups)
      groups.flat_map { |group| [ group.keep_id, *group.duplicate_ids ] }
    end

    # validate that each group's institutions have the correct ROR IDs in the institutions table and if
    # something doesn't match then raise an error to prevent accidental overwriting of existing ROR IDs
    def validate_group_ror_ids!(group, existing_ror_ids)
      group_institution_ids(group).each do |institution_id|
        current_ror_id = existing_ror_ids.fetch(institution_id)
        next if current_ror_id.blank? || current_ror_id == group.ror_id

        raise ArgumentError, "Institution #{institution_id} already has ROR ID #{current_ror_id}, not #{group.ror_id}."
      end
    end

    # all ids in a group by ROR
    def group_institution_ids(group)
      [ group.keep_id, *group.duplicate_ids ]
    end

    # apply the groups to the database, updating references and deleting duplicates, returning a hash of updated
    # references and the count of deleted institutions
    def apply_groups(connection, groups)
      updated_references = Hash.new(0)
      reference_columns = institution_reference_columns(connection)
      deleted_count = groups.sum do |group|
        apply_group(connection, group, reference_columns, updated_references)
      end

      [ updated_references, deleted_count ]
    end

    # apply a single group to the database, updating references and deleting duplicates, returning
    # the count of deleted institutions
    def apply_group(connection, group, reference_columns, updated_references)
      assign_ror_id(group) if group.set_ror_id

      group.duplicate_ids.sum do |duplicate_id|
        merge_duplicate(connection, group, duplicate_id, reference_columns, updated_references)
      end
    end

    # assign the ROR ID to the retained institution in the group
    def assign_ror_id(group)
      Institution.find(group.keep_id).update!(ror_id: group.ror_id)
    end

    # merge a duplicate institution into the retained institution, updating references and recording the deletion
    def merge_duplicate(connection, group, duplicate_id, reference_columns, updated_references)
      reference_updates = update_references(
        connection, reference_columns, duplicate_id, group.keep_id, updated_references
      )
      record_deletion(connection, group, duplicate_id, reference_updates)
      delete_institution(duplicate_id)
    end

    # update all references to the old institution ID with the new institution ID, returning a hash of updated references
    def update_references(connection, reference_columns, old_id, new_id, updated_references)
      reference_columns.to_h do |table_name, column_name|
        count = update_reference(connection, table_name, column_name, old_id, new_id)
        updated_references[table_name] += count
        [ table_name, count ]
      end.select { |_table_name, count| count.positive? }
    end

    # delete the institution with the given ID, raising an error if it was not deleted
    def delete_institution(institution_id)
      deleted = Institution.where(id: institution_id).delete_all
      raise "Institution #{institution_id} was not deleted." unless deleted == 1

      deleted
    end

    # record the deletion of a duplicate institution in the audit table, including the reference updates
    def record_deletion(connection, group, deleted_institution_id, reference_updates)
      connection.exec_insert(audit_insert_sql(connection, group, deleted_institution_id, reference_updates))
    end

    # generate the SQL for inserting a record into the audit table
    def audit_insert_sql(connection, group, deleted_institution_id, reference_updates)
      <<~SQL
        INSERT INTO institution_deduplication_audits (
          run_id, source_csv_path, source_csv_sha256, ror_id,
          retained_institution_id, deleted_institution_id, reference_updates, created_at, updated_at
        ) VALUES (
          #{connection.quote(@audit_run_id)},
          #{connection.quote(@csv_path)},
          #{connection.quote(source_csv_sha256)},
          #{connection.quote(group.ror_id)},
          #{connection.quote(group.keep_id)},
          #{connection.quote(deleted_institution_id)},
          #{connection.quote(JSON.generate(reference_updates))},
          CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
        )
      SQL
    end

    def source_csv_sha256
      @source_csv_sha256 ||= Digest::SHA256.file(@csv_path).hexdigest
    end

    # return an array of [table_name, column_name] pairs for all columns that reference institution_id
    def institution_reference_columns(connection)
      # Scan the live schema so every current institution_id reference is moved before deletion.
      references = connection.tables.flat_map { |table_name| institution_id_columns(connection, table_name) }
      references << [ "institutions", "managing_institution_id" ] if managing_institution_id?(connection)
      references
    end

    # return an array of [table_name, column_name] pairs for all columns in the given table that reference institution_id
    def institution_id_columns(connection, table_name)
      connection.columns(table_name).filter_map do |column|
        [ table_name, column.name ] if column.name == "institution_id"
      end
    end

    # return true if the institutions table has a managing_institution_id column, false otherwise
    def managing_institution_id?(connection)
      connection.columns(:institutions).any? { |column| column.name == "managing_institution_id" }
    end

    # update all references to the old institution ID with the new institution ID in the given table and column, returning the number of rows updated
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
