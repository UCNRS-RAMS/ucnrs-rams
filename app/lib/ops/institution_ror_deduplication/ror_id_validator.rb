# frozen_string_literal: true

module Ops
  module InstitutionRorDeduplication
    # Prevents merging institutions that already carry a ROR ID different from the CSV's ROR ID.
    # Blank ROR IDs are allowed because the retained institution is given the CSV's ROR ID.
    class RorIdValidator
      def initialize(groups)
        @groups = groups
      end

      def validate!
        @groups.each { |group| validate_group!(group) }
      end

      private

      # current ROR IDs as stored in the institutions table, keyed by institution ID
      def existing_ror_ids
        @existing_ror_ids ||= Institution.where(id: @groups.flat_map(&:institution_ids)).pluck(:id, :ror_id).to_h
      end

      def validate_group!(group)
        group.institution_ids.each do |institution_id|
          current_ror_id = existing_ror_ids.fetch(institution_id)
          next if current_ror_id.blank? || current_ror_id == group.ror_id

          raise ArgumentError, "Institution #{institution_id} already has ROR ID #{current_ror_id}, not #{group.ror_id}."
        end
      end
    end
  end
end
