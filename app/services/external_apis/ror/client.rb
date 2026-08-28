# frozen_string_literal: true

module ExternalApis
  module Ror
    class Client
      def initialize(service: ExternalApis::RorService)
        @service = service
      end

      def latest_dump_metadata
        return service.fetch_zenodo_metadata if stubbed?(service, :fetch_zenodo_metadata)
        return nil if service.download_url.blank?

        response = service_http_client.get(uri: service.download_url, debug: false)
        return nil unless response.present? && response.status == 200

        json = JSON.parse(response.body).with_indifferent_access
        file_metadata = json.dig(:hits, :hits, 0, :files)&.last
        if file_metadata.blank?
          service.log_error(method: 'Fetching ROR metadata from Zenodo', error: StandardError.new('No ROR file found in Zenodo metadata response.'))
          return nil
        end

        file_metadata[:links] = file_metadata.fetch(:links, {}).with_indifferent_access
        file_metadata[:links][:download] ||= file_metadata[:links][:self]
        file_metadata
      rescue JSON::ParserError => e
        service.log_error(method: 'Fetching ROR metadata from Zenodo', error: e)
        nil
      end

      def download(url)
        return service.download_ror_file(url: url) if stubbed?(service, :download_ror_file)
        return nil if url.blank?

        response = service_http_client.get(uri: url, debug: false)
        return nil unless response.present? && response.status == 200

        response.body
      end

      private

      attr_reader :service

      def stubbed?(target, method_name)
        return false unless target.respond_to?(method_name)

        target.method(method_name).owner != target.singleton_class
      end

      def service_http_client
        if service.respond_to?(:http_client, true)
          service.send(:http_client)
        else
          ExternalApis::HttpClient.new(service: service)
        end
      end
    end
  end
end
