# frozen_string_literal: true

module Api
  module V1
    # Serializes a Visit for the public JSON contract. Attributes are listed
    # explicitly so database columns are never exposed by default: the visits
    # table mixes the activity record with free-text notes, a visitor sign-in
    # token, and internal report-access flags.
    #
    # A visit ties a project to the reserve it took place at and carries the
    # activity window, so it also embeds the visiting party — the submitter and
    # each user_visit — as entity stubs.
    class VisitPresenter < BasePresenter
      private

      # @return [Hash{Symbol=>Object}]
      def attributes
        {
          status: record.status,
          purpose_of_visit: record.purpose_of_visit,
          public_use_category: record.public_use_category,
          study_area: record.study_area,
          start_date: date(record.start_date),
          end_date: date(record.end_date),
          starts_at: timestamp(record.starts_at),
          ends_at: timestamp(record.ends_at),
          submitted_at: timestamp(record.submitted_at),
          project: project_stub,
          reserve: reserve_stub,
          submitter: submitter_stub,
          visitors: visitor_stubs,
          created_at: timestamp(record.created_at),
          updated_at: timestamp(record.updated_at)
        }
      end

      # @return [Hash, nil] the project stub, or nil when the visit names no
      #   project
      def project_stub
        project = record.project
        return nil if project.nil?

        entity("projects", project.id, title: project.title, project_type: project.project_type)
      end

      # @return [Hash, nil] the reserve stub, or nil when the visit names no
      #   reserve
      def reserve_stub
        reserve = record.reserve
        return nil if reserve.nil?

        entity("reserves", reserve.id, name: reserve.name, short_name: reserve.short_name)
      end

      # @return [Hash, nil] the stub of the person who submitted the visit, or
      #   nil when the visit names none
      def submitter_stub
        user_stub(record.user)
      end

      # @return [Array<Hash>] one entry per user_visit, ordered by id so the
      #   payload is deterministic
      def visitor_stubs
        record.user_visits.sort_by(&:id).map { |user_visit| visitor_stub(user_visit) }
      end

      # @param user_visit [UserVisit]
      # @return [Hash] the visiting party, its role and institution, and dates
      def visitor_stub(user_visit)
        {
          user: user_stub(user_visit.user),
          role: user_visit.role,
          institution: institution_stub(user_visit.institution),
          arrives_at: timestamp(user_visit.arrives_at),
          departs_at: timestamp(user_visit.departs_at),
          count: user_visit.count
        }
      end

      # @param user [User, nil]
      # @return [Hash, nil]
      def user_stub(user)
        return nil if user.nil?

        entity("users", user.id, full_name: user.full_name, orcid: user.orcid)
      end

      # @param institution [Institution, nil]
      # @return [Hash, nil]
      def institution_stub(institution)
        return nil if institution.nil?

        entity("institutions", institution.id, name: institution.name, acronym: institution.acronym)
      end
    end
  end
end
