# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExternalApis::Ror::Client do
  let(:http_client) { instance_double(ExternalApis::HttpClient) }
  let(:logger) { instance_double(ExternalApis::Logger, error: nil) }
  let(:metadata_url) { 'https://zenodo.org/api/records/?communities=ror-data' }
  let(:client) { described_class.new(http_client: http_client, metadata_url: metadata_url, logger: logger) }

  describe '#latest_dump_metadata' do
    it 'returns the latest file metadata with a normalized download link' do
      response = instance_double(
        Faraday::Response,
        status: 200,
        body: {
          'hits' => {
            'hits' => [{ 'files' => [{ 'key' => 'ror-data.zip', 'checksum' => 'md5:abc123',
                                       'links' => { 'self' => 'https://example.test/ror.zip' } }] }]
          }
        }.to_json
      )
      allow(http_client).to receive(:get).with(uri: metadata_url, debug: false).and_return(response)

      expect(client.latest_dump_metadata).to include(
        checksum: 'md5:abc123',
        links: { self: 'https://example.test/ror.zip', download: 'https://example.test/ror.zip' }
      )
    end

    it 'logs malformed metadata' do
      response = instance_double(Faraday::Response, status: 200, body: '{')
      allow(http_client).to receive(:get).and_return(response)

      expect(client.latest_dump_metadata).to be_nil
      expect(logger).to have_received(:error).with(context: 'ROR metadata', error: an_instance_of(JSON::ParserError))
    end
  end

  describe '#download' do
    it 'returns the response body for a successful request' do
      response = instance_double(Faraday::Response, status: 200, body: 'zip contents')
      allow(http_client).to receive(:get).with(uri: 'https://example.test/ror.zip', debug: false).and_return(response)

      expect(client.download('https://example.test/ror.zip')).to eq('zip contents')
    end
  end
end
