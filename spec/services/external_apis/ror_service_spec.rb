# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExternalApis::RorService do
  describe '.fetch_zenodo_metadata' do
    let(:response) { instance_double(HTTParty::Response, code: 200, body: body) }

    before do
      allow(described_class).to receive(:http_get).and_return(response)
    end

    context 'when Zenodo returns search results' do
      let(:body) do
        {
          'hits' => {
            'hits' => [
              {
                'files' => [
                  {
                    'checksum' => 'md5:abc123',
                    'links' => { 'self' => 'https://zenodo.org/records/1/files/ror.zip/content' },
                  },
                ],
              },
            ],
          },
        }.to_json
      end

      it 'returns the latest file metadata' do
        metadata = described_class.send(:fetch_zenodo_metadata)

        expect(metadata).to include(
          checksum: 'md5:abc123',
          links: {
            self: 'https://zenodo.org/records/1/files/ror.zip/content',
            download: 'https://zenodo.org/records/1/files/ror.zip/content',
          },
        )
      end
    end

    context 'when Zenodo returns an unexpected payload shape' do
      let(:body) { { 'hits' => {} }.to_json }

      it 'returns nil through the existing failure path' do
        allow(described_class).to receive(:handle_http_failure)
        allow(described_class).to receive(:notify_administrators)

        expect(described_class.send(:fetch_zenodo_metadata)).to be_nil
      end
    end

    describe '.download_ror_file' do
      let(:response) { instance_double(HTTParty::Response, code: 200, body: 'zip file contents') }

      it 'requests the Zenodo file with the required Accept header' do
        allow(described_class).to receive(:http_get)
          .with(
            uri: 'https://zenodo.org/api/records/1/files/ror.zip/content',
            additional_headers: { host: 'zenodo.org', Accept: 'application/json' },
            debug: false,
          ).and_return(response)

        expect(
          described_class.send(:download_ror_file, url: 'https://zenodo.org/api/records/1/files/ror.zip/content'),
        ).to eq('zip file contents')
      end
    end
  end
end
