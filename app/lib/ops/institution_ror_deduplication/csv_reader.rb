# frozen_string_literal: true

require "csv"

module Ops
  module InstitutionRorDeduplication
    # Reads and validates the ROR spreadsheet, returning normalized rows.
    class CsvReader
      # headers are from the Danny CSV file from google sheets which is expected to have this header row
      # rams_id,rams_name,rams_acronym,rams_city,ror_id,ror_name,ror_match_type but only the items below are used
      REQUIRED_HEADERS = %w[rams_id ror_id ror_match_type].freeze

      def initialize(csv_path)
        @csv_path = csv_path
      end

      # @return [Array<Hash>] rows with :rams_id, :ror_id and :ror_match_type keys
      def rows
        table = CSV.read(@csv_path, headers: true, header_converters: :symbol, encoding: "bom|utf-8")
        validate_headers!(table)

        rows = parse_rows(table)
        validate_direct_mappings!(rows)
        rows
      end

      private

      def validate_headers!(table)
        missing_headers = REQUIRED_HEADERS - table.headers.compact.map(&:to_s)
        return if missing_headers.empty?

        raise ArgumentError, "CSV is missing required headers: #{missing_headers.join(', ')}"
      end

      def parse_rows(table)
        rows = table.filter_map { |row| parse_row(row) }
        raise ArgumentError, "CSV contains no data rows." if rows.empty?

        rows
      end

      def parse_row(row)
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
      def validate_direct_mappings!(rows)
        conflicting_ids = direct_mappings(rows).filter_map do |rams_id, mappings|
          rams_id if mappings.map { |row| row[:ror_id] }.uniq.many?
        end
        return if conflicting_ids.empty?

        raise ArgumentError, "Direct CSV rows map institution IDs to multiple ROR IDs: #{conflicting_ids.join(', ')}."
      end

      # only rows of type "direct" may be used to merge institutions, ignore others when validating CSV
      def direct_mappings(rows)
        rows.select { |row| row[:ror_match_type] == "direct" }.group_by { |row| row[:rams_id] }
      end
    end
  end
end
