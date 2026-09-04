# frozen_string_literal: true

require 'rails_helper'
require 'zip'

RSpec.describe ExternalApis::Ror::Sync do
  let(:directory) { Rails.root.join('tmp/ror_sync_spec') }
  let(:config) do
    ExternalApis::Ror::Config.new(
      download_url: 'https://example.test/metadata',
      file_dir: directory,
      checksum_file: directory.join('checksum.txt'),
      zip_file: directory.join('archive.zip'),
      max_redirects: 3,
      user_agent: 'RSpec'
    )
  end
  let(:client) { instance_double(ExternalApis::Ror::Client) }
  let(:logger) { instance_double(ExternalApis::Logger, info: nil, warn: nil, error: nil) }
  let(:sync) { described_class.new(client: client, config: config, logger: logger) }

  before do
    FileUtils.rm_rf(directory)
    Ror.delete_all
  end

  after { FileUtils.rm_rf(directory) }

  def metadata
    {
      checksum: 'def456',
      key: 'ror-data.zip',
      links: { download: 'https://example.test/ror-data.zip' }
    }
  end

  def build_archive(records)
    FileUtils.mkdir_p(directory)
    Zip::File.open(config.zip_file, create: true) do |zip|
      zip.get_output_stream('ror-data.json') { |stream| stream.write(records.to_json) }
    end
    config.zip_file
  end

  describe '#call' do
    it 'returns failure when metadata cannot be retrieved' do
      allow(client).to receive(:latest_dump_metadata).and_return(nil)

      expect(sync.call).to eq(:failure)
    end

    it 'skips an archive whose checksum was already imported' do
      FileUtils.mkdir_p(directory)
      File.write(config.checksum_file, 'abc123')
      allow(client).to receive(:latest_dump_metadata).and_return({ checksum: 'abc123' })

      expect(sync.call).to eq(:no_change)
    end

    it 'downloads, imports, and records a new archive checksum' do
      metadata = {
        checksum: 'def456',
        key: 'ror-data.zip',
        links: { download: 'https://example.test/ror-data.zip' }
      }
      allow(client).to receive(:latest_dump_metadata).and_return(metadata)
      allow(client).to receive(:download).with('https://example.test/ror-data.zip').and_return('zip payload')
      allow(sync).to receive(:process_ror_file).with(zip_file: config.zip_file, file: 'ror-data.json').and_return(true)

      expect(sync.call).to eq(:success)
      expect(File.binread(config.zip_file)).to eq('zip payload')
      expect(File.read(config.checksum_file)).to eq('def456')
    end

    it 'imports a valid archive and removes stale cached records' do
      create(:ror, ror_id: 'https://ror.org/stale', file_timestamp: 1.day.ago)
      archive = build_archive([{ 'id' => 'https://ror.org/current', 'name' => 'Current University' }])
      allow(client).to receive(:latest_dump_metadata).and_return(metadata)
      allow(client).to receive(:download).with(metadata.dig(:links, :download)).and_return(File.binread(archive))

      expect(sync.call).to eq(:success)
      expect(Ror.pluck(:ror_id)).to eq(['https://ror.org/current'])
      expect(File.read(config.checksum_file)).to eq('def456')
    end

    it 'preserves cached records and does not record the checksum for a malformed archive' do
      stale_ror = create(:ror, ror_id: 'https://ror.org/stale', file_timestamp: 1.day.ago)
      archive = build_archive({ 'id' => 'https://ror.org/not-an-array' })
      allow(client).to receive(:latest_dump_metadata).and_return(metadata)
      allow(client).to receive(:download).with(metadata.dig(:links, :download)).and_return(File.binread(archive))

      expect(sync.call).to eq(:failure)
      expect(Ror.find_by(ror_id: stale_ror.ror_id)).to be_present
      expect(File.exist?(config.checksum_file)).to be(false)
    end

    it 'preserves cached records and does not record the checksum when a record cannot be imported' do
      stale_ror = create(:ror, ror_id: 'https://ror.org/stale', file_timestamp: 1.day.ago)
      archive = build_archive([
                                { 'id' => 'https://ror.org/current', 'name' => 'Current University' },
                                { 'name' => 'Missing identifier' }
                              ])
      allow(client).to receive(:latest_dump_metadata).and_return(metadata)
      allow(client).to receive(:download).with(metadata.dig(:links, :download)).and_return(File.binread(archive))

      expect(sync.call).to eq(:failure)
      expect(Ror.find_by(ror_id: stale_ror.ror_id)).to be_present
      expect(File.exist?(config.checksum_file)).to be(false)
    end
  end

  describe '#process_ror_record' do
    it 'persists attributes mapped from a valid ROR record' do
      record = {
        'id' => 'https://ror.org/1234567890',
        'names' => [{ 'value' => 'Example University', 'types' => ['ror_display'] }],
        'links' => [{ 'type' => 'website', 'value' => 'https://example.edu' }],
        'country' => { 'country_name' => 'United States', 'country_code' => 'US' }
      }

      expect(sync.send(:process_ror_record, record: record, time: Time.current)).to be(true)
      expect(Ror.find_by!(ror_id: record['id']).name).to eq('Example University (example.edu)')
    end
  end

  describe '#unzip_file' do
    it 'extracts an archive into a Pathname destination' do
      FileUtils.mkdir_p(directory)
      Zip::File.open(config.zip_file, create: true) do |zip|
        zip.get_output_stream('ror-data.json') { |stream| stream.write('[]') }
      end

      expect(sync.send(:unzip_file, zip_file: config.zip_file, destination: config.file_dir)).to be(true)
      expect(File.read(directory.join('ror-data.json'))).to eq('[]')
    end

    it 'rejects an archive entry outside the import directory' do
      FileUtils.mkdir_p(directory)
      Zip::File.open(config.zip_file, create: true) do |zip|
        zip.get_output_stream('../outside.json') { |stream| stream.write('[]') }
      end

      expect(sync.send(:unzip_file, zip_file: config.zip_file, destination: config.file_dir)).to be(false)
      expect(logger).to have_received(:error).with(
        context: 'ROR import',
        error: an_instance_of(StandardError)
      )
    end
  end
end
