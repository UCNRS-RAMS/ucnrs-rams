# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExternalApis::RorService do
  describe '.fetch_zenodo_metadata' do
    let(:response) { instance_double(Faraday::Response, status: 200, body: body) }
    let(:client) { instance_double(ExternalApis::HttpClient) }

    before do
      allow(described_class).to receive(:download_url).and_return('https://zenodo.org/api/records/?communities=ror-data&sort=mostrecent')
      allow(described_class).to receive(:http_client).and_return(client)
      allow(client).to receive(:get).and_return(response)
    end

    context 'when Zenodo returns a valid result set' do
      let(:body) do
        {
          'hits' => {
            'hits' => [
              {
                'files' => [
                  {
                    'key' => 'ror-data.zip',
                    'checksum' => 'md5:abc123',
                    'links' => { 'self' => 'https://zenodo.org/records/1/files/ror.zip/content' }
                  }
                ]
              }
            ]
          }
        }.to_json
      end

      it 'returns the latest file metadata with a download link' do
        metadata = described_class.send(:fetch_zenodo_metadata)

        expect(metadata).to include(
          checksum: 'md5:abc123',
          links: {
            self: 'https://zenodo.org/records/1/files/ror.zip/content',
            download: 'https://zenodo.org/records/1/files/ror.zip/content'
          }
        )
      end
    end

    context 'when Zenodo returns an unexpected payload shape' do
      let(:body) { { 'hits' => {} }.to_json }

      it 'returns nil and logs an invalid metadata response' do
        allow(described_class).to receive(:log_error)

        expect(described_class.send(:fetch_zenodo_metadata)).to be_nil
        expect(described_class).to have_received(:log_error).with(
          method: 'Fetching ROR metadata from Zenodo',
          error: an_instance_of(StandardError)
        )
      end
    end
  end

  describe '.download_ror_file' do
    let(:url) { 'https://zenodo.org/api/records/1/files/ror.zip/content' }
    let(:client) { instance_double(ExternalApis::HttpClient) }

    before do
      allow(described_class).to receive(:http_client).and_return(client)
    end

    it 'returns the response body when the request succeeds' do
      response = instance_double(Faraday::Response, status: 200, body: 'zip file contents')
      allow(client).to receive(:get).with(
        uri: url,
        debug: false
      ).and_return(response)

      expect(described_class.send(:download_ror_file, url: url)).to eq('zip file contents')
    end

    it 'returns nil when no URL is provided' do
      expect(described_class.send(:download_ror_file, url: nil)).to be_nil
    end

    it 'handles a non-200 response by calling the failure handler' do
      response = instance_double(Faraday::Response, status: 403, body: 'forbidden')
      allow(client).to receive(:get).and_return(response)
      allow(described_class).to receive(:handle_http_failure)

      expect(described_class.send(:download_ror_file, url: url)).to be_nil
    end
  end

  describe '.fetch' do
    before do
      allow(described_class).to receive(:file_dir).and_return(Rails.root.join('tmp/ror_test'))
      allow(FileUtils).to receive(:mkdir_p)
      allow(described_class).to receive(:download_url).and_return('https://zenodo.org/api/records/?communities=ror-data')
    end

    it 'returns :failure when Zenodo metadata cannot be fetched' do
      allow(described_class).to receive(:fetch_zenodo_metadata).and_return(nil)

      expect(described_class.fetch).to eq(:failure)
    end

    it 'returns :no_change when the cached checksum matches the latest metadata' do
      allow(described_class).to receive(:fetch_zenodo_metadata).and_return({ checksum: 'abc123' })
      allow(File).to receive(:exist?).with(described_class.checksum_file).and_return(true)
      allow(File).to receive(:read).with(described_class.checksum_file).and_return('abc123')

      expect(described_class.fetch).to eq(:no_change)
    end

    it 'downloads and processes a new ROR archive successfully' do
      allow(described_class).to receive(:fetch_zenodo_metadata).and_return(
        {
          checksum: 'def456',
          key: 'ror-data.zip',
          links: { download: 'https://zenodo.org/records/1/files/ror-data.zip/content' }
        }
      )
      allow(File).to receive(:exist?).with(described_class.checksum_file).and_return(false)
      allow(described_class).to receive(:download_ror_file).with(url: 'https://zenodo.org/records/1/files/ror-data.zip/content').and_return('zip payload')
      allow(described_class).to receive(:process_ror_file).with(zip_file: described_class.zip_file, file: 'ror-data.json').and_return(true)
      allow(File).to receive(:binwrite)
      allow(File).to receive(:write)

      expect(described_class.fetch).to eq(:success)
    end

    it 'returns :failure when metadata does not include an archive key' do
      allow(described_class).to receive(:fetch_zenodo_metadata).and_return(
        {
          checksum: 'def456',
          links: { download: 'https://zenodo.org/records/1/files/ror-data.zip/content' }
        }
      )
      allow(File).to receive(:exist?).with(described_class.checksum_file).and_return(false)

      expect(described_class.fetch).to eq(:failure)
    end
  end

  describe '.process_ror_record' do
    let(:record) do
      {
        'id' => 'https://ror.org/1234567890',
        'name' => 'Example University',
        'links' => [{ 'type' => 'website', 'value' => 'https://example.edu' }],
        'types' => ['Education'],
        'names' => [
          { 'value' => 'Example University', 'types' => ['ror_display'] },
          { 'value' => 'Example', 'types' => ['alias'] }
        ],
        'country' => { 'country_name' => 'United States', 'country_code' => 'US' },
        'external_ids' => { 'FundRef' => { 'preferred' => '123', 'all' => ['123', '456'] } }
      }
    end

    before { Ror.delete_all }

    it 'creates a ROR record with the expected metadata and website context' do
      expect(described_class.send(:process_ror_record, record: record, time: Time.current)).to be(true)

      ror = Ror.find_by(ror_id: record['id'])
      expect(ror).not_to be_nil
      expect(ror.name).to end_with('(example.edu)')
      expect(ror.name).to include('Example University')
      expect(ror.acronyms).to eq([])
      expect(ror.aliases).to eq(['Example'])
      expect(ror.country).to eq({ 'country_name' => 'United States', 'country_code' => 'US' })
      expect(ror.types).to eq(['Education'])
      expect(ror.fundref_id).to eq('123')
      expect(ror.home_page).to eq('https://example.edu')
    end

    it 'returns nil for invalid records' do
      expect(described_class.send(:process_ror_record, record: { 'name' => 'Missing ID' }, time: Time.current)).to be_nil
    end
  end

  describe 'record parsing helpers' do
    describe '.ror_names' do
      it 'returns matching values by name type' do
        item = {
          'names' => [
            { 'value' => 'Example University', 'types' => ['ror_display'] },
            { 'value' => 'Example', 'types' => ['alias'] },
            { 'value' => 'EU', 'types' => ['acronym'] }
          ]
        }

        expect(described_class.send(:ror_names, item: item, type: 'alias')).to eq(['Example'])
        expect(described_class.send(:ror_names, item: item, type: 'acronym')).to eq(['EU'])
      end
    end

    describe '.country_data' do
      it 'uses the top-level country hash when present' do
        item = { 'country' => { 'country_name' => 'United States', 'country_code' => 'US' } }

        expect(described_class.send(:country_data, item: item)).to eq({ 'country_name' => 'United States', 'country_code' => 'US' })
      end

      it 'falls back to geonames details when country is not present' do
        item = {
          'locations' => [
            { 'geonames_details' => { 'country_name' => 'Mexico', 'country_code' => 'MX' } }
          ]
        }

        expect(described_class.send(:country_data, item: item)).to eq({ 'country_name' => 'Mexico', 'country_code' => 'MX' })
      end
    end

    describe '.org_name' do
      it 'returns the raw name when no extra context is present' do
        item = { 'name' => 'Example College', 'links' => [], 'country' => {}, 'names' => [] }

        expect(described_class.send(:org_name, item: item)).to eq('Example College')
      end

      it 'keeps the website context when a display name is present' do
        item = {
          'name' => 'Legacy Name',
          'links' => [{ 'type' => 'website', 'value' => 'https://example.edu/path' }],
          'country' => { 'country_name' => 'Nowhere' },
          'names' => [{ 'value' => 'Preferred Name', 'types' => ['ror_display'] }]
        }

        name = described_class.send(:org_name, item: item)
        expect(name).to include('example.edu')
        expect(name).to include('Preferred Name')
      end

      it 'falls back to the country when the website is missing' do
        item = {
          'name' => 'Example College',
          'country' => { 'country_name' => 'Nowhere' },
          'links' => []
        }

        expect(described_class.send(:org_name, item: item)).to eq('Example College (Nowhere)')
      end
    end

    describe '.org_language' do
      it 'defaults to English for US organizations' do
        item = { 'country' => { 'country_code' => 'US' } }

        expect(described_class.send(:org_language, item: item)).to eq('en')
      end

      it 'uses the language from the preferred name when available' do
        item = { 'names' => [{ 'lang' => 'es', 'value' => 'Universidad', 'types' => ['ror_display'] }] }

        expect(described_class.send(:org_language, item: item)).to eq('es')
      end

      it 'falls back to the legacy labels iso639 value' do
        item = { 'labels' => [{ 'iso639' => 'fr' }] }

        expect(described_class.send(:org_language, item: item)).to eq('fr')
      end
    end

    describe '.primary_website' do
      it 'returns the first website link when present' do
        item = { 'links' => [{ 'type' => 'website', 'value' => 'https://example.edu' }, { 'type' => 'other', 'value' => 'https://example.org' }] }

        expect(described_class.send(:primary_website, item: item)).to eq('https://example.edu')
      end

      it 'returns the first string URL when the links array contains plain strings' do
        item = { 'links' => ['https://example.edu/path'] }

        expect(described_class.send(:primary_website, item: item)).to eq('https://example.edu/path')
      end
    end

    describe '.org_website' do
      it 'strips the protocol and www prefix to keep the domain only' do
        item = { 'links' => ['https://www.example.edu/path?a=b'] }

        expect(described_class.send(:org_website, item: item)).to eq('example.edu')
      end

      it 'returns nil when there is no usable website' do
        expect(described_class.send(:org_website, item: { 'links' => [] })).to be_nil
      end
    end

    describe '.fundref_id' do
      it 'returns an empty string when no fundref info is present' do
        expect(described_class.send(:fundref_id, item: { 'external_ids' => {} })).to eq('')
      end

      it 'returns the preferred fundref when the external IDs include a FundRef hash' do
        item = { 'external_ids' => { 'FundRef' => { 'preferred' => '1', 'all' => ['2', '1'] } } }

        expect(described_class.send(:fundref_id, item: item)).to eq('1')
      end

      it 'falls back to the first FundRef value when no preferred value exists' do
        item = { 'external_ids' => { 'fundref' => { 'preferred' => nil, 'all' => ['2', '1'] } } }

        expect(described_class.send(:fundref_id, item: item)).to eq('2')
      end
    end
  end
end
