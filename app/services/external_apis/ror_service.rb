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
        Rails.configuration.x.ror&.landing_page_url || super
      end

      def api_base_url
        Rails.configuration.x.ror&.api_base_url || super
      end

      def download_url
        Rails.configuration.x.ror&.download_url
      end

      def full_catalog_file
        Rails.configuration.x.ror&.full_catalog_file || Rails.root.join("tmp/ror/ror.json")
      end

      def file_dir
        Rails.configuration.x.ror&.file_dir || Rails.root.join("tmp/ror")
      end

      def checksum_file
        Rails.configuration.x.ror&.checksum_file || Rails.root.join("tmp/ror/checksum.txt")
      end

      def zip_file
        Rails.configuration.x.ror&.zip_file || Rails.root.join("tmp/ror/latest-ror-data.zip")
      end

      def active?
        Rails.configuration.x.ror&.active.nil? ? super : Rails.configuration.x.ror.active
      end

      def heartbeat_path
        Rails.configuration.x.ror&.heartbeat_path
      end

      def search_path
        Rails.configuration.x.ror&.search_path
      end


      def fetch(force: false)
        force = ActiveModel::Type::Boolean.new.cast(force)
        method = "ExternalApis::RorService.fetch(force: #{force})"

        log_message(method: method, message: 'Starting ROR sync: checking Zenodo metadata')

        # Fetch the Zenodo metadata for ROR to see if we have the latest data dump
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

      private

      # Fetch the latest Zenodo metadata for ROR files
      def fetch_zenodo_metadata
        Rails.logger.error 'No :download_url defined for RorService!' if download_url.blank?
        return nil if download_url.blank?

        # Fetch the latest ROR metadata from Zenodo (the query will place the most recent
        # version 1st)
        resp = http_client.get(uri: download_url, debug: false)

        unless resp.present? && resp.status == 200
          handle_http_failure(method: 'Fetching ROR metadata from Zenodo', http_response: resp)
          return nil
        end
        json = JSON.parse(resp.body).with_indifferent_access

        # Extract the most recent file's metadata
        file_metadata = json.dig(:hits, :hits, 0, :files)&.last
        if file_metadata.blank?
          log_error(method: 'Fetching ROR metadata from Zenodo', error: StandardError.new('No ROR file found in Zenodo metadata response.'))
          return nil
        end

        file_metadata[:links] = file_metadata.fetch(:links, {}).with_indifferent_access
        file_metadata[:links][:download] ||= file_metadata[:links][:self]
        file_metadata
      rescue JSON::ParserError => e
        log_error(method: 'RorService', error: e)
        nil
      end
      # rubocop:enable Metrics/AbcSize

      # Download the latest ROR data
      def download_ror_file(url:)
        return nil if url.blank?

        resp = http_client.get(uri: url, debug: false)

        unless resp.present? && resp.status == 200
          handle_http_failure(method: "Fetching ROR file from Zenodo - #{url}", http_response: resp)
          return nil
        end
        resp.body
      end

      # Parse the JSON file and process each individual record
      # rubocop:disable Metrics/AbcSize
      def process_ror_file(zip_file:, file:)
        return false unless zip_file.present? && file.present?

        method = 'ExternalApis::RorService.process_ror_file'

        if unzip_file(zip_file: zip_file, destination: file_dir)
          if File.exist?("#{file_dir}/#{file}")
            json_file = File.open("#{file_dir}/#{file}", 'r')
            json = JSON.parse(json_file.read)
            total = json.length
            interval = progress_interval_for(total)

            log_message(method: method, message: "Stage: populate - starting record processing for #{total} records; progress updates every #{interval} records")

            json.each_with_index do |hash, index|
              current = index + 1
              log_message(method: method, message: "Progress: #{current}/#{total} records (#{percentage(current, total)}%)") if should_log_progress?(current, total, interval)

              hash = hash.with_indifferent_access if hash.is_a?(Hash)

              next if process_ror_record(record: hash, time: json_file.mtime)

              log_message(
                method: method,
                message: "Unable to process record #{current}/#{total} for: '#{hash&.fetch('name', hash&.fetch('id', 'unknown'))}'",
                info: false
              )
            end

            # cleanup items removed from ror
            log_message(method: method, message: "Stage: cleanup - removing stale records older than #{json_file.mtime.strftime('%Y-%m-%d %H:%M:%S')}")
            Ror.where('file_timestamp < ?', json_file.mtime).delete_all
            log_message(method: method, message: "Stage: complete - finished processing #{total} ROR records")
            true
          else
            log_error(method: method, error: StandardError.new('Unable to find json in zip!'))
            false
          end
        else
          log_error(method: method, error: StandardError.new('Unable to unzip contents of ROR file'))
          false
        end
      rescue JSON::ParserError => e
        log_error(method: method, error: e)
        false
      end
      # rubocop:enable Metrics/AbcSize

      # interval for updated info based on the size of the total records.
      def progress_interval_for(total_records)
        return 1 if total_records <= 1
        return 100 if total_records <= 1000
        return 1000 if total_records <= 10_000

        10_000
      end

      def should_log_progress?(current_record, total_records, interval)
        current_record == total_records || (current_record % interval).zero?
      end

      def percentage(current_record, total_records)
        return 0 if total_records.zero?

        ((current_record.to_f / total_records) * 100).round(1)
      end
            # Transfer the contents of a ROR record to the local rors table
            def process_ror_record(record:, time:)
              attrs = Ror::RecordMapper.call(record)
              return nil if attrs.blank? || attrs[:ror_id].blank?

              ror_model = Ror.find_or_create_by(ror_id: attrs[:ror_id])
              ror_model.assign_attributes(attrs.except(:ror_id).merge(file_timestamp: time))

              ror_model.save!
              true
      rescue StandardError => e
        record_id = record['id'] || record['ror_id'] || 'unknown'
        detail = "Record #{record_id} failed during ROR population: #{e.message}"
        log_error(method: 'ExternalApis::RorService.process_ror_record', error: StandardError.new(detail))
        log_message(method: 'ExternalApis::RorService.process_ror_record', message: "Payload for failed record: #{record.to_s[0, 1000]}", info: false)
        false
      end
    end
  end
end
