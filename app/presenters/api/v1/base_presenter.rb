# frozen_string_literal: true

module Api
  module V1
    # Shared serialization helpers for the JSON API contract.
    #
    # Presenters expose an explicit allowlist of fields; database columns are
    # never serialized implicitly. Belongs-to associations are embedded as
    # "entity stubs" (type + id + a small label) so a client can follow a
    # relationship without a second request.
    class BasePresenter
      # @param record [Object] the record to serialize
      def initialize(record)
        @record = record
      end

      # @return [Object] the record being serialized
      attr_reader :record

      # @return [Hash{Symbol=>Object}] the +id+, +type+, and allowlisted fields
      def as_json
        { id: record.id, type: self.class.resource_type }.merge(attributes)
      end

      # @return [String] the pluralized resource name, derived from the class name
      def self.resource_type
        @resource_type ||= name.demodulize.sub(/Presenter\z/, "").underscore.pluralize
      end

      private

      # @return [Hash{Symbol=>Object}] the allowlisted attributes for the record
      # @raise [NotImplementedError] when a subclass does not define it
      def attributes
        raise NotImplementedError, "#{self.class} must define #attributes"
      end

      # @param type [String] the related resource type, e.g. +"reserves"+
      # @param id [Integer] the related record's id
      # @param fields [Hash] the short label fields to embed
      # @return [Hash]
      def entity(type, id, **fields)
        { type: type, id: id }.merge(fields)
      end

      # @param value [Date, nil]
      # @return [String, nil] an ISO 8601 date
      def date(value)
        value&.iso8601
      end

      # @param value [Time, nil]
      # @return [String, nil] an ISO 8601 UTC timestamp
      def timestamp(value)
        value&.utc&.iso8601
      end
    end
  end
end
