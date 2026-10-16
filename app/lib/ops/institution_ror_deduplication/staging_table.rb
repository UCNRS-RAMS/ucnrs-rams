# frozen_string_literal: true

module Ops
  module InstitutionRorDeduplication
    # A temporary, non-model table holding the CSV rows so they can be joined to institutions in SQL.
    # The table is session-scoped and dropped when the block given to .with finishes.
    class StagingTable
      BATCH_SIZE = 500

      # Creates and fills the table, yields it, and always drops it afterward.
      def self.with(connection, rows)
        table = new(connection)
        table.create
        table.import(rows)
        yield table
      ensure
        table&.drop
      end

      def initialize(connection)
        @connection = connection
        @name = "institution_ror_import_#{SecureRandom.hex(6)}"
        @quoted_name = connection.quote_table_name(@name)
      end

      def create
        @connection.create_table(@name, temporary: true, id: false) do |table|
          table.integer :rams_id, null: false
          table.string :ror_id
          table.string :ror_match_type, null: false
        end
      end

      def import(rows)
        rows.each_slice(BATCH_SIZE) { |batch| insert_batch(batch) }
      end

      def drop
        @connection.execute("DROP TEMPORARY TABLE IF EXISTS #{@quoted_name}")
      end

      # direct CSV institution IDs that do not exist in the institutions table
      def missing_institution_ids
        @connection.select_values(<<~SQL)
          SELECT DISTINCT imported.rams_id
          FROM #{@quoted_name} AS imported
          LEFT JOIN institutions ON institutions.id = imported.rams_id
          WHERE imported.ror_match_type = 'direct'
            AND institutions.id IS NULL
        SQL
      end

      # "direct" rows are on the same level as the ROR institution (not children or related institutions)
      def direct_matches
        @connection.select_all(<<~SQL).to_a
          SELECT DISTINCT institutions.id AS institution_id, imported.ror_id, institutions.ror_id AS current_ror_id
          FROM #{@quoted_name} AS imported
          INNER JOIN institutions ON institutions.id = imported.rams_id
          WHERE imported.ror_match_type = 'direct'
          ORDER BY imported.ror_id, institutions.id
        SQL
      end

      private

      # batched to avoid exceeding the maximum query length
      def insert_batch(batch)
        values = batch.map { |row| quoted_values(row) }
        @connection.execute(
          "INSERT INTO #{@quoted_name} (rams_id, ror_id, ror_match_type) VALUES #{values.join(', ')}"
        )
      end

      def quoted_values(row)
        values = row.values_at(:rams_id, :ror_id, :ror_match_type).map { |value| @connection.quote(value) }
        "(#{values.join(', ')})"
      end
    end
  end
end
