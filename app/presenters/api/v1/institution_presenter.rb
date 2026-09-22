# frozen_string_literal: true

module Api
  module V1
    # Serializes an Institution for the public JSON contract. Attributes are
    # listed explicitly so database columns are never exposed by default.
    # The public contract uses the Rails enum key for +institution_type+, which
    # matches the values accepted by the query filter.
    class InstitutionPresenter < BasePresenter
      private

      # @return [Hash{Symbol=>Object}]
      def attributes
        {
          name: record.name,
          acronym: record.acronym,
          city: record.city,
          institution_type: record.institution_type,
          country: country_stub,
          state: state_stub,
          ror: ror_stub,
          created_at: timestamp(record.created_at),
          updated_at: timestamp(record.updated_at),
        }
      end

      # @return [Hash, nil] the country stub, or nil when the institution has no country
      def country_stub
        country = record.country
        return nil if country.nil?

        entity("countries", country.id, name: country.name)
      end

      # @return [Hash, nil] the state stub, or nil when the institution has no state
      def state_stub
        state = record.state
        return nil if state.nil?

        entity("states", state.id, name: state.name)
      end

      # @return [Hash, nil] the ROR stub, or nil when the institution has no
      #   matching Research Organization Registry record
      def ror_stub
        ror = record.ror
        return nil if ror.nil?

        entity("rors", ror.id, ror_id: ror.ror_id, name: ror.name)
      end
    end
  end
end
