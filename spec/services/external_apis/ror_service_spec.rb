# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExternalApis::RorService do
  describe '.fetch_zenodo_metadata' do
    let(:response) { instance_double(HTTParty::Response, code: 200, body: body) }

    before do
      allow(described_class).to receive(:download_url).and_return('https://zenodo.org/api/records/?communities=ror-data')
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
            additional_headers: hash_including(
              host: 'zenodo.org',
              Accept: 'application/json',
              'Content-Type': 'application/json'
            ),
            debug: false,
          ).and_return(response)

        expect(
          described_class.send(:download_ror_file, url: 'https://zenodo.org/api/records/1/files/ror.zip/content'),
        ).to eq('zip file contents')
      end
    end
  end

  describe '.fetch' do
    let(:tmp_dir) { Rails.root.join('tmp', 'spec-ror') }
    let(:checksum_path) { tmp_dir.join('checksum.txt') }
    let(:zip_path) { tmp_dir.join('latest-ror-data.zip') }
    let(:metadata) do
      {
        checksum: 'md5:abc123',
        key: 'latest-ror-data.zip',
        links: {
          download: 'https://zenodo.org/api/records/1/files/latest-ror-data.zip/content',
        },
      }.with_indifferent_access
    end

    before do
      FileUtils.rm_rf(tmp_dir)
      FileUtils.mkdir_p(tmp_dir)
      allow(described_class).to receive(:file_dir).and_return(tmp_dir)
      allow(described_class).to receive(:checksum_file).and_return(checksum_path)
      allow(described_class).to receive(:zip_file).and_return(zip_path)
      allow(described_class).to receive(:fetch_zenodo_metadata).and_return(metadata)
    end

    after do
      FileUtils.rm_rf(tmp_dir)
    end

    it 'returns :no_change when the checksum matches the cached value' do
      File.write(checksum_path, metadata[:checksum])

      expect(described_class.fetch).to eq(:no_change)
    end

    it 'returns :success when the file is downloaded and processed' do
      allow(described_class).to receive(:download_ror_file).and_return('zip payload')
      allow(described_class).to receive(:process_ror_file).and_return(true)

      expect(described_class.fetch).to eq(:success)
      expect(File.read(checksum_path)).to eq(metadata[:checksum])
    end
  end
end
