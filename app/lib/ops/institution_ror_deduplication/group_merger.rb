# frozen_string_literal: true

module Ops
  module InstitutionRorDeduplication
    # Merges each duplicate institution in a group into the retained one.
    class GroupMerger
      def initialize(reference_updater, audit_log)
        @reference_updater = reference_updater
        @audit_log = audit_log
      end

      # @return [Integer] number of institutions deleted
      def merge(group)
        assign_ror_id(group) if group.set_ror_id

        group.duplicate_ids.sum { |duplicate_id| merge_duplicate(group, duplicate_id) }
      end

      private

      def assign_ror_id(group)
        Institution.find(group.keep_id).update!(ror_id: group.ror_id)
      end

      # references move and the audit row is written before the delete, all inside the caller's transaction
      def merge_duplicate(group, duplicate_id)
        reference_updates = @reference_updater.move(duplicate_id, group.keep_id)
        @audit_log.record(group, duplicate_id, reference_updates)
        delete_institution(duplicate_id)
      end

      # delete_all skips callbacks and dependent checks, which is safe only because references were moved first
      def delete_institution(institution_id)
        deleted = Institution.where(id: institution_id).delete_all
        raise "Institution #{institution_id} was not deleted." unless deleted == 1

        deleted
      end
    end
  end
end
