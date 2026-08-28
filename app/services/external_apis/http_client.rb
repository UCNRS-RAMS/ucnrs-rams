# frozen_string_literal: true

require 'faraday'
require 'faraday/follow_redirects'
require 'faraday/retry'
require 'logger'

module ExternalApis
  # Shared HTTP client for external API services.
  class HttpClient
    def initialize(service:)
      @service = service
    end

    def get(uri:, additional_headers: {}, debug: false)
      request(method: :get, uri: uri, additional_headers: additional_headers, debug: debug)
    end

    def put(uri:, additional_headers: {}, data: {}, basic_auth: nil, debug: false)
      request(method: :put, uri: uri, additional_headers: additional_headers,
              data: data, basic_auth: basic_auth, debug: debug)
    end

    def post(uri:, additional_headers: {}, data: {}, basic_auth: nil, debug: false)
      request(method: :post, uri: uri, additional_headers: additional_headers,
              data: data, basic_auth: basic_auth, debug: debug)
    end

    private

    attr_reader :service

    def request(method:, uri:, additional_headers:, data: nil, basic_auth: nil, debug: false)
      return nil if uri.blank?

      connection = faraday_connection(uri: uri, additional_headers: additional_headers,
                                      debug: debug, basic_auth: basic_auth)
      return connection.get(uri) if method == :get

      connection.public_send(method, uri, data)
    rescue URI::InvalidURIError => e
      service.send(:handle_uri_failure, method: "#{service_name}.http_#{method} #{e.message}", uri: uri)
      nil
    rescue Faraday::Error => e
      service.send(:handle_http_failure, method: "#{service_name}.http_#{method} #{e.message}", http_response: nil)
      nil
    end

    def faraday_connection(uri:, additional_headers: {}, debug: false, basic_auth: nil)
      connection = Faraday.new(
        uri,
        headers: service.headers.merge(additional_headers),
        request: { timeout: 60, open_timeout: 30 }
      ) do |f|
        f.request :retry, max: 6,
                          interval: 0.5,
                          backoff_factor: 2,
                          methods: %i[get post put],
                          retry_statuses: [429, 500, 502, 503, 504]
        f.response :follow_redirects, limit: service.max_redirects
        f.response :logger, Logger.new($stdout), bodies: true if debug
        f.adapter Faraday.default_adapter
      end

      if basic_auth.present?
        connection.request(:authorization, :basic,
                           basic_auth[:username], basic_auth[:password])
      end

      connection
    end

    def service_name
      service.name || service.to_s
    end
  end
end
