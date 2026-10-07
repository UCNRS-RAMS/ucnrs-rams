# frozen_string_literal: true

module Ops
  # Merges institutions that the ROR spreadsheet marks as direct matches for the same ROR ID,
  # keeping the lowest institution ID in each group. See Ops::InstitutionRorDeduplication for the collaborators.
  class InstitutionRorDeduplicator
    include InstitutionRorDeduplication

    Result = Struct.new(:groups, :updated_references, :deleted_count, :audit_run_id, keyword_init: true)

    def initialize(csv_path)
      @csv_path = csv_path
    end

    def call(apply: false)
      rows = CsvReader.new(@csv_path).rows

      ActiveRecord::Base.connection_pool.with_connection do |connection|
        StagingTable.with(connection, rows) do |staging_table|
          groups = GroupPlanner.new(staging_table).groups
          RorIdValidator.new(groups).validate!

          apply ? merge_groups(connection, groups) : dry_run_result(groups)
        end
      end
    end

    private

    def dry_run_result(groups)
      Result.new(groups: groups, updated_references: {}, deleted_count: 0, audit_run_id: nil)
    end

    # one transaction so a failure leaves neither moved references nor audit rows behind
    def merge_groups(connection, groups)
      with_advisory_lock(connection) do
        Institution.transaction do
          reference_updater = ReferenceUpdater.new(connection)
          audit_log = AuditLog.new(connection, @csv_path)
          merger = GroupMerger.new(reference_updater, audit_log)

          deleted_count = groups.sum { |group| merger.merge(group) }

          Result.new(
            groups: groups,
            updated_references: reference_updater.totals,
            deleted_count: deleted_count,
            audit_run_id: audit_log.run_id
          )
        end
      end
    end

    # Acquires a MySQL session-level advisory lock (GET_LOCK) to ensure only one
    # deduplication run executes at a time across application processes, without
    # locking database tables.
    def with_advisory_lock(connection)
      return yield unless connection.adapter_name.downcase.include?("mysql")

      lock_name = "ops_institution_ror_deduplication"
      acquired = connection.select_value(
        "SELECT GET_LOCK(#{connection.quote(lock_name)}, 0)"
      ).to_i == 1

      raise "Could not acquire advisory lock '#{lock_name}'. Another deduplication run is active." unless acquired

      begin
        yield
      ensure
        connection.execute("SELECT RELEASE_LOCK(#{connection.quote(lock_name)})")
      end
    end
  end
end
