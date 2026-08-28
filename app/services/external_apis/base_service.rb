# frozen_string_literal: true

require 'digest'
require 'zip'

module ExternalApis
  # Errors for External Api services
  class ExternalApiError < StandardError; end

  # Abstract service that provides HTTP methods for individual external api services
  class BaseService
    class << self
      # The following should be defined in each inheriting service's initializer.
      # For example:
      #   ExternalApis::RorService.setup do |config|
      #     config.x.ror.landing_page_url = "https://example.org/"
      #     config.x.ror.api_base_url = "https://api.example.org/"
      #   end
      def landing_page_url
        raise NotImplementedError
      end

      def api_base_url
        raise NotImplementedError
      end

      def max_pages
        5
      end

      def max_results_per_page
        50
      end

      def max_redirects
        3
      end

      def active?
        false
      end

      # The standard headers to be used when communicating with an external API.
      # These headers can be overriden or added to when calling an external API
      # by sending your changes in the `additional_headers` attribute of
      # `http_get`
      def headers
        {
          'Content-Type': 'application/json',
          Accept: 'application/json',
          'User-Agent': "#{app_name} (#{app_email})"
        }
      end

      # Logs the results of a failed HTTP response
      def handle_http_failure(method:, http_response:)
        status = http_response&.status
        content = http_response&.inspect || 'nil'
        msg = "received a #{status} response with: #{content}!"
        log_error(method: method, error: ExternalApiError.new(msg))
      end

      # Logs the results of a failed HTTP response
      def handle_uri_failure(method:, uri:)
        msg = "received an invalid uri: '#{uri}'!"
        log_error(method: method, error: ExternalApiError.new(msg))
      end

      # Logs the specified error along with the full backtrace
      def log_error(method:, error:)
        return unless method.present? && error.present?

        output = "#{name || to_s}.#{method} #{error.message}"
        Rails.logger.error output
        Rails.logger.error error.backtrace
        print_to_console(output, level: :error)
      end

      # Logs the specified message (as INFO by default, WARN otherwise)
      def log_message(method:, message:, info: true)
        return unless method.present? && message.present?

        output = "#{name || to_s}.#{method} #{message}"
        Rails.logger.send((info ? :info : :warn), output)
        print_to_console(output, level: info ? :info : :warn)
      end

      def print_to_console(output, level: :info)
        return if output.blank?

        # Long-running external sync jobs need stdout output in dev/CLI runs even when Rails
        # is configured to write logs elsewhere.
        return unless Rails.env.development? || Rails.env.dev_server? || ENV["RAILS_LOG_TO_STDOUT"].present?

        prefix = level == :error ? "ERROR" : level == :warn ? "WARN" : "INFO"
        $stdout.puts "[#{prefix}] #{output}"
      end

      private

      # Retrieves the application name from the initializer or uses the App name
      def app_name
        ApplicationService.application_name
      end

      # Retrieves the helpdesk email from dmproadmap.rb initializer or uses the contact page url
      def app_email
        Rails.configuration.x.organization.fetch(:helpdesk_email) do
          Rails.application.routes.url_helpers.contact_us_url || ''
        end
      end

      # Makes a GET request to the specified uri with the additional headers.
      # Additional headers are combined with the base headers defined above.
      def http_get(uri:, additional_headers: {}, debug: false)
        http_client.get(uri: uri, additional_headers: additional_headers, debug: debug)
      end

      # Makes a PUT request to the specified uri with the additional headers.
      # Additional headers are combined with the base headers defined above.
      def http_put(uri:, additional_headers: {}, data: {}, basic_auth: nil, debug: false)
        http_client.put(uri: uri, additional_headers: additional_headers,
                        data: data, basic_auth: basic_auth, debug: debug)
      end

      # Makes a POST request to the specified uri with the additional headers.
      # Additional headers are combined with the base headers defined above.
      def http_post(uri:, additional_headers: {}, data: {}, basic_auth: nil, debug: false)
        http_client.post(uri: uri, additional_headers: additional_headers,
                         data: data, basic_auth: basic_auth, debug: debug)
      end

      def http_client
        HttpClient.new(service: self)
      end

      # Unzips the specified file
      def unzip_file(zip_file:, destination:)
        return false unless zip_file.present? && File.exist?(zip_file)

        destination = File.expand_path(destination.to_s)
        FileUtils.mkdir_p(destination)

        Zip::File.open(zip_file) do |zip|
          zip.each do |entry|
            next if entry.name.to_s.end_with?('/')

            f_path = File.join(destination, entry.name)
            FileUtils.mkdir_p(File.dirname(f_path))
            next if File.exist?(f_path)

            File.binwrite(f_path, zip.read(entry))
          end
        end
        true
      rescue StandardError => e
        log_error(method: 'BaseService.unzip_file', error: e)
        false
      end

      # Determine if the downloaded file matches the expected checksum
      def validate_downloaded_file(file_path:, checksum:)
        return false unless file_path.present? && checksum.present? && File.exist?(file_path)

        # Strip whitespace, convert to lowercase, and remove common algorithm prefixes
        # Matches formats like: md5:, sha256:, sha-256=, {md5}, {sha256}:, etc.
        prefix_regex = /\A(?:\{?(?:md5|sha-?\d+|crc32)\}?[:=]|\{(?:md5|sha-?\d+|crc32)\})/i
        cleaned_checksum = checksum.to_s.strip.downcase.sub(prefix_regex, '')

        possible_checksums = [
          Digest::SHA1.file(file_path).hexdigest,
          Digest::SHA256.file(file_path).hexdigest,
          Digest::SHA512.file(file_path).hexdigest,
          Digest::MD5.file(file_path).hexdigest
        ]

        possible_checksums.include?(cleaned_checksum)
      end
    end
  end
end
