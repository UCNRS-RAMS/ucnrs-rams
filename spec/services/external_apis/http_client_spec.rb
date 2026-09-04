# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExternalApis::HttpClient do
  let(:logger) { instance_double(ExternalApis::Logger, error: nil) }
  let(:client) do
    described_class.new(
      headers: { Accept: 'application/json' },
      max_redirects: 4,
      logger: logger,
      name: 'Test API'
    )
  end

  describe '#get' do
    let(:response) { instance_double(Faraday::Response, status: 200, body: 'ok', inspect: 'HTTP 200') }

    it 'returns nil when uri is blank' do
      expect(client.get(uri: nil)).to be_nil
    end

    it 'returns the response for a valid request' do
      connection = instance_double(Faraday::Connection)
      allow(client).to receive(:faraday_connection).and_return(connection)
      allow(connection).to receive(:get).with('https://example.com').and_return(response)

      expect(client.get(uri: 'https://example.com')).to eq(response)
    end

    it 'logs and returns nil when the URI is invalid' do
      allow(client).to receive(:faraday_connection).and_raise(URI::InvalidURIError.new('bad'))

      expect(client.get(uri: 'badurl~^(%')).to be_nil
      expect(logger).to have_received(:error).with(
        context: 'Test API.get',
        error: an_instance_of(ExternalApis::HttpClient::RequestError)
      )
    end

    it 'logs and returns nil when Faraday raises an error' do
      allow(client).to receive(:faraday_connection).and_raise(Faraday::TimeoutError.new('timeout'))

      expect(client.get(uri: 'https://example.com')).to be_nil
      expect(logger).to have_received(:error).with(
        context: 'Test API.get',
        error: an_instance_of(ExternalApis::HttpClient::RequestError)
      )
    end
  end

  describe '#put' do
    it 'passes through the payload and basic auth options' do
      response = instance_double(Faraday::Response, status: 200, body: 'ok', inspect: 'HTTP 200')
      connection = instance_double(Faraday::Connection)
      allow(client).to receive(:faraday_connection).and_return(connection)
      allow(connection).to receive(:put).with('https://example.com', { foo: 'bar' }).and_return(response)

      expect(client.put(uri: 'https://example.com', data: { foo: 'bar' }, basic_auth: { username: 'user', password: 'pass' })).to eq(response)
    end
  end

  describe '#post' do
    it 'passes through the payload and basic auth options' do
      response = instance_double(Faraday::Response, status: 201, body: 'created', inspect: 'HTTP 201')
      connection = instance_double(Faraday::Connection)
      allow(client).to receive(:faraday_connection).and_return(connection)
      allow(connection).to receive(:post).with('https://example.com', { foo: 'bar' }).and_return(response)

      expect(client.post(uri: 'https://example.com', data: { foo: 'bar' }, basic_auth: { username: 'user', password: 'pass' })).to eq(response)
    end
  end

  describe '#faraday_connection' do
    it 'builds a standard Faraday connection with headers and timeout settings' do
      result = client.send(
        :faraday_connection,
        uri: 'https://example.com',
        additional_headers: { 'X-Test' => 'yes' }
      )

      expect(result.headers).to include('Accept' => 'application/json', 'X-Test' => 'yes')
      expect(result.options.timeout).to eq(60)
      expect(result.options.open_timeout).to eq(30)
      expect(result.builder.handlers).to include(Faraday::FollowRedirects::Middleware)
    end

    it 'configures basic authentication when present' do
      result = client.send(
        :faraday_connection,
        uri: 'https://example.com',
        basic_auth: { username: 'user', password: 'pass' }
      )

      expect(result.builder.handlers).to include(Faraday::Request::Authorization)
    end

    it 'configures request logging when debug is enabled' do
      result = client.send(:faraday_connection, uri: 'https://example.com', debug: true)

      expect(result.builder.handlers).to include(Faraday::Response::Logger)
    end
  end
end
