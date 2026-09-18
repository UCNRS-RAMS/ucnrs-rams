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
      def initialize(record)
        @record = record
      end

      attr_reader :record

      def as_json
        { id: record.id, type: self.class.resource_type }.merge(attributes)
      end

      def self.resource_type
        @resource_type ||= name.demodulize.sub(/Presenter\z/, "").underscore.pluralize
      end

      private

      def attributes
        raise NotImplementedError, "#{self.class} must define #attributes"
      end

      def entity(type, id, **fields)
        { type: type, id: id }.merge(fields)
      end

      def date(value)
        value&.iso8601
      end

      def timestamp(value)
        value&.utc&.iso8601
      end
    end
  end
end
