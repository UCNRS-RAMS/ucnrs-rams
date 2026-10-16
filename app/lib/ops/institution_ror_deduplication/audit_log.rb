# frozen_string_literal: true

require "digest"
require "json"

module Ops
  module InstitutionRorDeduplication
    # Persists one institution_deduplication_audits row per deleted institution.
    class AuditLog
      attr_reader :run_id

      def initialize(connection, csv_path)
        @connection = connection
        @csv_path = csv_path
        @run_id = SecureRandom.uuid
      end

      def record(group, deleted_institution_id, reference_updates)
        @connection.exec_insert(insert_sql(group, deleted_institution_id, reference_updates))
      end

      private

      def insert_sql(group, deleted_institution_id, reference_updates)
        <<~SQL
          INSERT INTO institution_deduplication_audits (
            run_id, source_csv_path, source_csv_sha256, ror_id,
            retained_institution_id, deleted_institution_id, reference_updates, created_at, updated_at
          ) VALUES (
            #{@connection.quote(run_id)},
            #{@connection.quote(@csv_path)},
            #{@connection.quote(source_csv_sha256)},
            #{@connection.quote(group.ror_id)},
            #{@connection.quote(group.keep_id)},
            #{@connection.quote(deleted_institution_id)},
            #{@connection.quote(JSON.generate(reference_updates))},
            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
          )
        SQL
      end

      # lets a later reader confirm which version of the spreadsheet drove the run
      def source_csv_sha256
        @source_csv_sha256 ||= Digest::SHA256.file(@csv_path).hexdigest
      end
    end
  end
end
