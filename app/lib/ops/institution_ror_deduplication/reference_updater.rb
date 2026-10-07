# frozen_string_literal: true

module Ops
  module InstitutionRorDeduplication
    # Repoints every institution reference from one institution ID to another.
    class ReferenceUpdater
      # @return [Hash{String => Integer}] rows updated per table across every move
      attr_reader :totals

      def initialize(connection)
        @connection = connection
        @columns = reference_columns
        @totals = Hash.new(0)
      end

      # @return [Hash{String => Integer}] rows updated per table for this move, omitting tables with none
      def move(old_id, new_id)
        @columns.to_h do |table_name, column_name|
          count = repoint_column(table_name, column_name, old_id, new_id)
          @totals[table_name] += count
          [ table_name, count ]
        end.select { |_table_name, count| count.positive? }
      end

      # Checks if any rows still reference old_id across all referencing tables.
      # Under MySQL InnoDB's default REPEATABLE READ isolation level, a plain SELECT reads
      # from the transaction's initial snapshot and would miss rows inserted or updated by
      # concurrent web requests. Using FOR UPDATE forces a locking current read that inspects
      # the latest committed data in each table.
      # @return [Array<String>] list of "table.column (count)" for any remaining references
      def remaining_references(old_id)
        @columns.filter_map do |table_name, column_name|
          quoted_table = @connection.quote_table_name(table_name)
          quoted_column = @connection.quote_column_name(column_name)

          count = @connection.select_value(<<~SQL).to_i
            SELECT COUNT(*)
            FROM #{quoted_table}
            WHERE #{quoted_column} = #{@connection.quote(old_id)}
            FOR UPDATE
          SQL

          "#{table_name}.#{column_name} (#{count})" if count.positive?
        end
      end

      private

      # Scan the live schema so every current institution reference is moved before deletion.
      def reference_columns
        references = @connection.tables.flat_map { |table_name| institution_id_columns(table_name) }
        references << [ "institutions", "managing_institution_id" ] if managing_institution_id?
        references << [ "reserves", "managing_campus_id" ] if managing_campus_id?
        references
      end

      def institution_id_columns(table_name)
        @connection.columns(table_name).filter_map do |column|
          [ table_name, column.name ] if column.name == "institution_id"
        end
      end

      def managing_institution_id?
        @connection.columns(:institutions).any? { |column| column.name == "managing_institution_id" }
      end

      def managing_campus_id?
        @connection.columns(:reserves).any? { |column| column.name == "managing_campus_id" }
      end

      # @return [Integer] number of rows updated
      def repoint_column(table_name, column_name, old_id, new_id)
        quoted_table = @connection.quote_table_name(table_name)
        quoted_column = @connection.quote_column_name(column_name)

        @connection.update(<<~SQL)
          UPDATE #{quoted_table}
          SET #{quoted_column} = #{@connection.quote(new_id)}
          WHERE #{quoted_column} = #{@connection.quote(old_id)}
        SQL
      end
    end
  end
end
