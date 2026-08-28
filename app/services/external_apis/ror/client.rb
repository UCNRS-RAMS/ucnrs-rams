# frozen_string_literal: true

module ExternalApis
  module Ror
    class Client
      def initialize(http_client:, metadata_url:, logger:)
        @http_client = http_client
        @metadata_url = metadata_url
        @logger = logger
      end

      def latest_dump_metadata
        return nil if metadata_url.blank?

        response = http_client.get(uri: metadata_url, debug: false)
        return nil unless response.present? && response.status == 200

        json = JSON.parse(response.body).with_indifferent_access
        file_metadata = json.dig(:hits, :hits, 0, :files)&.last
        if file_metadata.blank?
          logger.error(context: 'ROR metadata', error: StandardError.new('No ROR file found in Zenodo metadata response.'))
          return nil
        end

        file_metadata[:links] = file_metadata.fetch(:links, {}).with_indifferent_access
        file_metadata[:links][:download] ||= file_metadata[:links][:self]
        file_metadata
      rescue JSON::ParserError => e
        logger.error(context: 'ROR metadata', error: e)
        nil
      end

      def download(url)
        return nil if url.blank?

        response = http_client.get(uri: url, debug: false)
        return nil unless response.present? && response.status == 200

        response.body
      end

      private

      attr_reader :http_client, :metadata_url, :logger
    end
  end
end
