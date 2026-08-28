# frozen_string_literal: true

require 'digest'

module ExternalApis
  # This service provides an interface to the Research Organization Registry (ROR)
  # API.
  # For more information: https://github.com/ror-community/ror-api
  class RorService < BaseService
    class << self
      # Retrieve the config settings from the initializer
      def landing_page_url
        ExternalApis::Ror::Config.landing_page_url
      end

      def api_base_url
        ExternalApis::Ror::Config.api_base_url
      end

      def download_url
        ExternalApis::Ror::Config.download_url
      end

      def full_catalog_file
        ExternalApis::Ror::Config.full_catalog_file
      end

      def file_dir
        ExternalApis::Ror::Config.file_dir
      end

      def checksum_file
        ExternalApis::Ror::Config.checksum_file
      end

      def zip_file
        ExternalApis::Ror::Config.zip_file
      end

      def active?
        ExternalApis::Ror::Config.active?
      end

      def heartbeat_path
        ExternalApis::Ror::Config.heartbeat_path
      end

      def search_path
        ExternalApis::Ror::Config.search_path
      end

      def fetch(force: false)
        force = ActiveModel::Type::Boolean.new.cast(force)
        method = "ExternalApis::RorService.fetch(force: #{force})"

        log_message(method: method, message: 'Starting ROR sync: checking Zenodo metadata')

        metadata = fetch_zenodo_metadata
        if metadata.blank?
          log_error(method: method, error: StandardError.new('Unable to fetch ROR metadata from Zenodo!'))
          return :failure
        end

        FileUtils.mkdir_p(file_dir)
        old_checksum_val = File.read(checksum_file) if File.exist?(checksum_file) && !force

        if old_checksum_val == metadata[:checksum]
          log_message(method: method, message: 'No new ROR file to process; checksum matches the cached copy.')
          return :no_change
        end

        download_link = metadata.dig(:links, :download)
        download_file = metadata[:key].presence
        if download_link.blank? || download_file.blank?
          log_error(method: method, error: StandardError.new('ROR metadata is missing a download link or archive key.'))
          return :failure
        end

        log_message(method: method, message: "New ROR file detected - checksum #{metadata[:checksum]}")
        log_message(method: method, message: "Stage: download - #{download_file}")
        log_message(method: method, message: "Source: #{download_link}")

        payload = download_ror_file(url: download_link)
        if payload.blank?
          log_error(method: method, error: StandardError.new('Unable to download ROR file!'))
          return :failure
        end

        File.binwrite(zip_file, payload)
        log_message(method: method, message: "Stage: save - downloaded archive written to #{zip_file}")

        json_file = "#{File.basename(download_file).delete_suffix('.zip')}.json"
        log_message(method: method, message: "Stage: populate - processing #{json_file} into the local ROR table")
        return :failure unless process_ror_file(zip_file: zip_file, file: json_file)

        log_message(method: method, message: "Stage: finalize - writing checksum #{metadata[:checksum]}")
        File.write(checksum_file, metadata[:checksum])
        log_message(method: method, message: 'ROR sync completed successfully.')
        :success
      end

      def fetch_zenodo_metadata
        ExternalApis::Ror::Client.new(service: self).latest_dump_metadata
      end

      def download_ror_file(url:)
        ExternalApis::Ror::Client.new(service: self).download(url)
      end

      def process_ror_file(zip_file:, file:)
        ExternalApis::Ror::Sync.new(service: self).send(:process_ror_file, zip_file: zip_file, file: file)
      end

      def process_ror_record(record:, time:)
        ExternalApis::Ror::Sync.new(service: self).send(:process_ror_record, record: record, time: time)
      end
    end
  end
end
