# frozen_string_literal: true

module Api
  module V1
    # Serializes a Project for the public JSON contract. Attributes are listed
    # explicitly so database columns are never exposed by default.
    # The public contract uses the Rails enum keys ("open", "research"), which
    # are stable, lowercase, and match the values accepted by query filters.
    class ProjectPresenter < BasePresenter
      private

      def attributes
        {
          title: record.title,
          status: record.status,
          project_type: record.project_type,
          abstract: record.abstract,
          discipline: record.discipline,
          discipline_other: record.discipline_other,
          keywords: record.keywords,
          taxonomic_keywords: record.taxonomic_keywords,
          thesis_title: record.thesis_title,
          course_title: record.course_title,
          course_number: record.course_number,
          start_date: date(record.start_date),
          end_date: date(record.end_date),
          submitted_at: timestamp(record.submitted_at),
          reserve: reserve_stub,
          owner: user_stub(record.owner),
          applicant: user_stub(record.applicant),
          created_at: timestamp(record.created_at),
          updated_at: timestamp(record.updated_at),
        }
      end

      def reserve_stub
        reserve = record.reserve
        return nil if reserve.nil?

        entity("reserves", reserve.id, name: reserve.name, short_name: reserve.short_name)
      end

      def user_stub(user)
        return nil if user.nil?

        entity("users", user.id, full_name: user.full_name, orcid: user.orcid)
      end
    end
  end
end
