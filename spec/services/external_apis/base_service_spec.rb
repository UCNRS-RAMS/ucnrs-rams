# frozen_string_literal: true

require 'rails_helper'
require 'tmpdir'
require 'zip'

RSpec.describe ExternalApis::BaseService do
  before do
    allow(described_class).to receive(:landing_page_url).and_return('https://example.com')
    allow(described_class).to receive(:api_base_url).and_return('https://api.example.com/')
    allow(Rails.logger).to receive(:error)
    allow(Rails.logger).to receive(:info)
    allow(Rails.logger).to receive(:warn)
  end

  describe '.default_configuration' do
    it 'provides the default limits and inactive status' do
      expect(described_class.max_pages).to eq(5)
      expect(described_class.max_results_per_page).to eq(50)
      expect(described_class.max_redirects).to eq(3)
      expect(described_class.active?).to be(false)
    end
  end

  describe '.headers' do
    it 'sets the JSON content and accept headers' do
      headers = described_class.headers

      expect(headers[:'Content-Type']).to eq('application/json')
      expect(headers[:Accept]).to eq('application/json')
    end

    it 'sets the host and user-agent headers from the app configuration' do
      original = Rails.configuration.x.organisation.helpdesk_email
      Rails.configuration.x.organisation.helpdesk_email = 'support@example.com'

      headers = described_class.headers

      expect(headers[:Host]).to eq('api.example.com')
      expect(headers[:'User-Agent']).to eq("#{described_class.send(:app_name)} (support@example.com)")
    ensure
      Rails.configuration.x.organisation.helpdesk_email = original
    end

    it 'falls back to a valid host header when the API base URL is invalid' do
      allow(described_class).to receive(:api_base_url).and_return('not a valid url')

      expect { described_class.headers }.not_to raise_error
      expect(described_class.headers).not_to have_key(:Host)
    end
  end

  describe '.handle_http_failure' do
    let(:response) { instance_double(Faraday::Response, status: 500, body: 'It failed', inspect: 'HTTP 500') }

    it 'logs the failure when the method name is present' do
      expect(described_class).to receive(:log_error).with(
        method: 'BaseService.fetch',
        error: an_instance_of(ExternalApis::ExternalApiError),
      )

      described_class.send(:handle_http_failure, method: 'BaseService.fetch', http_response: response)
    end

    it 'does not raise when the HTTP response is nil' do
      expect(described_class).to receive(:log_error).once
      expect { described_class.send(:handle_http_failure, method: 'BaseService.fetch', http_response: nil) }.not_to raise_error
    end
  end

  describe '.handle_uri_failure' do
    it 'logs the invalid URI when present' do
      expect(described_class).to receive(:log_error).with(
        method: 'BaseService.fetch',
        error: an_instance_of(ExternalApis::ExternalApiError),
      )

      described_class.send(:handle_uri_failure, method: 'BaseService.fetch', uri: 'https://bad url')
    end

    it 'still logs a failure when the uri is nil' do
      expect(described_class).to receive(:log_error).once
      described_class.send(:handle_uri_failure, method: 'BaseService.fetch', uri: nil)
    end
  end

  describe '.log_error' do
    it 'does nothing when the method or error is missing' do
      expect(Rails.logger).not_to receive(:error)

      described_class.log_error(method: nil, error: StandardError.new('broken'))
      described_class.log_error(method: 'BaseService.fetch', error: nil)
    end

    it 'logs the error message and stack trace' do
      error = begin
        raise StandardError, 'broken'
      rescue StandardError => e
        e
      end
      allow(described_class).to receive(:print_to_console)

      described_class.log_error(method: 'BaseService.fetch', error: error)

      expect(Rails.logger).to have_received(:error).with('Class.BaseService.fetch broken').at_least(:once)
      expect(Rails.logger).to have_received(:error).with(error.backtrace).at_least(:once)
    end
  end

  describe '.log_message' do
    before do
      allow(described_class).to receive(:print_to_console)
    end

    it 'does nothing when the method or message is missing' do
      expect(Rails.logger).not_to receive(:info)
      expect(Rails.logger).not_to receive(:warn)

      described_class.log_message(method: nil, message: 'hello')
      described_class.log_message(method: 'BaseService.fetch', message: nil)
    end

    it 'logs info messages by default' do
      described_class.log_message(method: 'BaseService.fetch', message: 'hello')

      expect(Rails.logger).to have_received(:info).with('Class.BaseService.fetch hello')
    end

    it 'logs warnings when info is false' do
      described_class.log_message(method: 'BaseService.fetch', message: 'hello', info: false)

      expect(Rails.logger).to have_received(:warn).with('Class.BaseService.fetch hello')
    end
  end

  describe '.print_to_console' do
    before do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('development'))
    end

    it 'prints the output when running in development' do
      expect($stdout).to receive(:puts).with('[INFO] test output')

      described_class.send(:print_to_console, 'test output', level: :info)
    end

    it 'prints errors with an ERROR prefix' do
      expect($stdout).to receive(:puts).with('[ERROR] failed output')

      described_class.send(:print_to_console, 'failed output', level: :error)
    end
  end

  describe '.notify_administrators' do
    it 'returns false when there is no object, response, or error' do
      expect(described_class.notify_administrators(obj: nil, response: nil, error: nil)).to be(false)
    end

    it 'logs the response and returns true for unexpected responses' do
      response = instance_double(Faraday::Response, inspect: 'HTTP 500', status: 500)

      expect(Rails.logger).to receive(:error).with('String received an unexpected response from ExternalApis::BaseService').ordered
      expect(Rails.logger).to receive(:error).with('HTTP 500').ordered

      expect(described_class.notify_administrators(obj: 'String', response: response, error: nil)).to be(true)
    end

    it 'logs the exception details when an error is supplied' do
      error = begin
        raise StandardError, 'broken'
      rescue StandardError => e
        e
      end

      expect(Rails.logger).to receive(:error).with('String received an unexpected response from ExternalApis::BaseService').ordered
      expect(Rails.logger).to receive(:error).with("#{error.class}: #{error.message}").ordered
      expect(Rails.logger).to receive(:error).with(error.backtrace).ordered

      expect(described_class.notify_administrators(obj: 'String', response: nil, error: error)).to be(true)
    end
  end

  describe 'private methods' do
    describe '.app_name' do
      it 'returns the application name from ApplicationService' do
        expect(described_class.send(:app_name)).to eq(ApplicationService.application_name)
      end
    end

    describe '.app_email' do
      it 'returns the configured helpdesk email when present' do
        original = Rails.configuration.x.organisation.helpdesk_email
        Rails.configuration.x.organisation.helpdesk_email = 'support@example.com'

        expect(described_class.send(:app_email)).to eq('support@example.com')
      ensure
        Rails.configuration.x.organisation.helpdesk_email = original
      end

      it 'falls back to the contact page URL when no helpdesk email is configured' do
        original = Rails.configuration.x.organisation.helpdesk_email
        Rails.configuration.x.organisation.helpdesk_email = nil
        allow(Rails.configuration.x.organisation).to receive(:fetch).with(:helpdesk_email).and_return('https://example.com/contact-us')

        expect(described_class.send(:app_email)).to eq('https://example.com/contact-us')
      ensure
        Rails.configuration.x.organisation.helpdesk_email = original
      end
    end

    describe '.http_get' do
      let(:response) { instance_double(Faraday::Response, status: 200, body: 'ok', inspect: 'HTTP 200') }

      it 'returns nil when uri is blank' do
        expect(described_class.send(:http_get, uri: nil)).to be_nil
      end

      it 'logs and returns nil when the URI is invalid' do
        allow(described_class).to receive(:handle_uri_failure)
        allow(described_class).to receive(:faraday_connection).and_raise(URI::InvalidURIError)

        expect(described_class.send(:http_get, uri: 'badurl~^(%')).to be_nil
        expect(described_class).to have_received(:handle_uri_failure)
      end

      it 'returns the response for a valid request' do
        connection = instance_double(Faraday::Connection)
        allow(described_class).to receive(:faraday_connection).and_return(connection)
        allow(connection).to receive(:get).with('https://example.com').and_return(response)

        expect(described_class.send(:http_get, uri: 'https://example.com')).to eq(response)
      end
    end

    describe '.http_put' do
      let(:response) { instance_double(Faraday::Response, status: 200, body: 'ok', inspect: 'HTTP 200') }

      it 'returns nil when uri is blank' do
        expect(described_class.send(:http_put, uri: nil)).to be_nil
      end

      it 'passes through the payload and basic auth options' do
        connection = instance_double(Faraday::Connection)
        allow(described_class).to receive(:faraday_connection).and_return(connection)
        allow(connection).to receive(:put).with('https://example.com', { foo: 'bar' }).and_return(response)

        expect(described_class.send(:http_put, uri: 'https://example.com', data: { foo: 'bar' }, basic_auth: { username: 'user', password: 'pass' })).to eq(response)
      end
    end

    describe '.http_post' do
      let(:response) { instance_double(Faraday::Response, status: 201, body: 'created', inspect: 'HTTP 201') }

      it 'returns nil when uri is blank' do
        expect(described_class.send(:http_post, uri: nil)).to be_nil
      end

      it 'passes through the payload and basic auth options' do
        connection = instance_double(Faraday::Connection)
        allow(described_class).to receive(:faraday_connection).and_return(connection)
        allow(connection).to receive(:post).with('https://example.com', { foo: 'bar' }).and_return(response)

        expect(described_class.send(:http_post, uri: 'https://example.com', data: { foo: 'bar' }, basic_auth: { username: 'user', password: 'pass' })).to eq(response)
      end
    end

    describe '.options' do
      it 'builds a standard Faraday config with headers and timeout settings' do
        allow(described_class).to receive(:headers).and_return({ Accept: 'application/json' })

        result = described_class.send(:options, additional_headers: { 'X-Test' => 'yes' }, debug: false)

        expect(result[:headers]).to eq({ Accept: 'application/json', 'X-Test' => 'yes' })
        expect(result[:follow_redirects]).to be(true)
        expect(result[:limit]).to eq(6)
        expect(result[:request]).to eq({ timeout: 60, open_timeout: 30 })
        expect(result[:debug_output]).to be_nil
      end

      it 'includes stdout for debug output when requested' do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('development'))
        allow(described_class).to receive(:headers).and_return({ Accept: 'application/json' })

        result = described_class.send(:options, additional_headers: {}, debug: true)

        expect(result[:debug_output]).to eq($stdout)
      end
    end

    describe '.unzip_file' do
      it 'returns false when the zip file is missing or blank' do
        expect(described_class.send(:unzip_file, zip_file: nil, destination: 'tmp/out')).to be(false)
      end

      it 'extracts files from a zip archive' do
        Dir.mktmpdir do |dir|
          zip_file = File.join(dir, 'archive.zip')
          destination = File.join(dir, 'extracted')

          Zip::File.open(zip_file, create: true) do |zip|
            zip.get_output_stream('nested/example.txt') { |file| file.write('hello world') }
          end

          expect(described_class.send(:unzip_file, zip_file: zip_file, destination: destination)).to be(true)
          expect(File.read(File.join(destination, 'nested', 'example.txt'))).to eq('hello world')
        end
      end
    end

    describe '.validate_downloaded_file' do
      it 'returns false when the checksum or file path is missing' do
        expect(described_class.send(:validate_downloaded_file, file_path: nil, checksum: 'abc')).to be(false)
        expect(described_class.send(:validate_downloaded_file, file_path: 'missing', checksum: 'abc')).to be(false)
      end

      it 'returns true when the file matches the provided SHA256 checksum' do
        Dir.mktmpdir do |dir|
          file_path = File.join(dir, 'artifact.txt')
          File.binwrite(file_path, 'hello world')
          checksum = "sha256:#{Digest::SHA256.file(file_path).hexdigest}"

          expect(described_class.send(:validate_downloaded_file, file_path: file_path, checksum: checksum)).to be(true)
        end
      end
    end
  end
end
