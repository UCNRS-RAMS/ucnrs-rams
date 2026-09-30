# frozen_string_literal: true

module Api
  module V1
    # Serializes a Reserve for the public JSON contract. Attributes are listed
    # explicitly so database columns are never exposed by default: the reserves
    # table mixes this public directory data with billing details, staff
    # credentials, and internal configuration.
    class ReservePresenter < BasePresenter
      # +reserves.doi+ defaults to "0" rather than NULL, so an untouched reserve
      # does not have the DOI "0" — it has none.
      UNSET_DOI = "0"

      private

      # @return [Hash{Symbol=>Object}]
      def attributes
        {
          name: record.name,
          short_name: record.short_name,
          description: record.description,
          doi: doi,
          year_reserve_established: year_reserve_established,
          home_page_url: record.home_page_url,
          latitude: latitude,
          longitude: longitude,
          address_line_1: record.address_line_1,
          address_line_2: record.address_line_2,
          address_city: record.address_city,
          address_postal_code: record.address_postal_code,
          country: country_stub,
          state: state_stub,
          managing_campus: managing_campus_stub,
          created_at: timestamp(record.created_at),
          updated_at: timestamp(record.updated_at)
        }
      end

      # @return [String, nil] the reserve DOI, or nil when the column holds its
      #   unset sentinel
      def doi
        value = record.doi.presence
        value unless value == UNSET_DOI
      end

      # @return [Integer, nil] the year the reserve was established, or nil when
      #   the column holds its unset default. Nothing was established in year 0,
      #   and production carries it as the placeholder.
      def year_reserve_established
        year = record.year_reserve_established
        year unless year.to_i.zero?
      end

      # The coordinates columns default to 0.0, which is a point in the Gulf of
      # Guinea rather than a place in RAMS. A reserve at 0, 0 has not been given
      # coordinates, so the payload says null; a reserve on the equator or the
      # prime meridian keeps the axis it does have.
      #
      # @return [Float, nil]
      def latitude
        record.latitude if coordinates_recorded?
      end

      # @return [Float, nil]
      def longitude
        record.longitude if coordinates_recorded?
      end

      # @return [Boolean]
      def coordinates_recorded?
        record.latitude.to_f != 0 || record.longitude.to_f != 0
      end

      # @return [Hash, nil] the managing campus stub, or nil when the reserve
      #   names no managing campus
      def managing_campus_stub
        campus = record.managing_campus
        return nil if campus.nil?

        entity("institutions", campus.id, name: campus.name, acronym: campus.acronym)
      end

      # @return [Hash, nil] the country stub, or nil when the reserve has no
      #   address country
      def country_stub
        country = record.address_country
        return nil if country.nil?

        entity("countries", country.id, code: country.code, name: country.name)
      end

      # @return [Hash, nil] the state stub, or nil when the reserve has no
      #   address state
      def state_stub
        state = record.address_state
        return nil if state.nil?

        entity("states", state.id, code: state.code, name: state.name)
      end
    end
  end
end
