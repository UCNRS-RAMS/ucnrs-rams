# frozen_string_literal: true

module Ops
  module InstitutionRorDeduplication
    # Joins the staged CSV to institutions and groups the matches by ROR ID.
    class GroupPlanner
      def initialize(staging_table)
        @staging_table = staging_table
      end

      # @return [Array<Group>]
      def groups
        validate_institution_ids!

        matches = @staging_table.direct_matches
        raise ArgumentError, "CSV contains no direct institution rows." if matches.empty?

        matches.group_by { |row| row.fetch("ror_id") }.map { |ror_id, rows| build_group(ror_id, rows) }
      end

      private

      def validate_institution_ids!
        missing_ids = @staging_table.missing_institution_ids
        return if missing_ids.empty?

        raise ArgumentError, "Direct CSV institution IDs not found in institutions: #{missing_ids.join(', ')}."
      end

      # keeps the lowest institution ID in the group and marks the others as duplicates
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
    end
  end
end
