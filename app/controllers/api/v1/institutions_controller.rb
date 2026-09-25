# frozen_string_literal: true

module Api
  module V1
    # Read-only access to the institutions an ApiClient is authorized to see.
    class InstitutionsController < Api::V1::BaseController
      # Accepted values for the +institution_type+ query filter.
      INSTITUTION_TYPE_FILTERS = Institution.institution_types.keys.freeze

      # @return [void]
      def index
        page = paginate(filtered_institutions)

        render_collection(page) { |institution| serialize(institution) }
      end

      # @return [void]
      def show
        render_resource(institution, presenter: InstitutionPresenter)
      end

      private

      # @return [Institution]
      # @raise [ActiveRecord::RecordNotFound] when the institution is unknown or
      #   outside the client's scope
      def institution
        @institution ||= authorized_institutions.includes(:country, :state, :ror).find(params[:id])
      end

      # @return [ActiveRecord::Relation<Institution>]
      def authorized_institutions
        read_scope.institutions.select(
          :id, :name, :acronym, :city, :institution_type, :country_id, :state_id, :ror_id,
          :created_at, :updated_at
        )
      end

      # @return [ActiveRecord::Relation<Institution>]
      def filtered_institutions
        # Offset pagination needs a total order: created_at alone ties, which can
        # duplicate or drop rows across pages. id breaks ties deterministically.
        scope = authorized_institutions.includes(:country, :state, :ror).recent_first.order(id: :desc)

        institution_type = enum_filter(:institution_type, INSTITUTION_TYPE_FILTERS)
        if institution_type.present?
          scope = scope.where(institution_type: Institution.institution_types.fetch(institution_type))
        end

        country = country_filter
        scope = scope.where(country_id: country.id) if country

        state = state_filter(country)
        scope = scope.where(state_id: state.id) if state

        scope
      end

      # The country named by the +country_code+ filter, or nil when the caller
      # did not filter. Codes are ISO 3166-1 alpha-2, the values in
      # +countries.code+
      #
      # @return [Country, nil]
      # @raise [InvalidFilter] when the code is present but names no country
      def country_filter
        code = params[:country_code].presence
        return nil if code.nil?

        Country.coded(code) ||
          raise(InvalidFilter, "country_code #{code.inspect} is not a known ISO 3166-1 alpha-2 country code")
      end

      # The state named by the +state_code+ filter within +country+, or nil when
      # the caller did not filter it. State codes are only unique within a
      # country — "MA" is both Massachusetts and Maranhao — so the code is
      # resolved against the filtered country and rejected without one.
      #
      # @param country [Country, nil] the country resolved from +country_code+
      # @return [State, nil]
      # @raise [InvalidFilter] when +state_code+ is present without
      #   +country_code+, or names no state in +country+
      def state_filter(country)
        code = params[:state_code].presence
        return nil if code.nil?

        raise(InvalidFilter, "state_code requires country_code") if country.nil?

        country.states.coded(code) ||
          raise(InvalidFilter, "state_code #{code.inspect} is not a state in #{country.name}")
      end

      # @param institution [Institution]
      # @return [Hash] the serialized institution
      def serialize(institution)
        InstitutionPresenter.new(institution).as_json
      end
    end
  end
end
