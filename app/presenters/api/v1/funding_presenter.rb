# frozen_string_literal: true

module Api
  module V1
    # Serializes a Funding for the public JSON contract. Award amounts are
    # intentionally excluded because they are not needed for research linkage.
    class FundingPresenter < BasePresenter
      private

      # @return [Hash{Symbol=>Object}]
      def attributes
        {
          title: record.title,
          grant_number: record.grant_number,
          sponsor: record.sponsor,
          sponsor_other: record.sponsor_other,
          funding_opportunity_number: record.funding_opportunity_number,
          principal_investigators: record.principal_investigators,
          co_principal_investigators: record.co_principal_investigators,
          is_funded: record.is_funded,
          is_submitted: record.is_submitted,
          will_be_submitted: record.will_be_submitted,
          was_denied: record.was_denied,
          start_date: date(record.start_date),
          end_date: date(record.end_date),
          project: project_stub,
          reserve: reserve_stub,
          created_at: timestamp(record.created_at),
          updated_at: timestamp(record.updated_at)
        }
      end

      # @return [Hash]
      def project_stub
        project = record.project
        entity("projects", project.id, title: project.title, project_type: project.project_type)
      end

      # @return [Hash, nil]
      def reserve_stub
        reserve = record.project.reserve
        return nil if reserve.nil?

        entity("reserves", reserve.id, name: reserve.name, short_name: reserve.short_name)
      end
    end
  end
end
