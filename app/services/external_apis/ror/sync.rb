# frozen_string_literal: true

require 'fileutils'
require 'zip'

module ExternalApis
  module Ror
    class Sync
      def self.from_rails
        config = Config.from_rails
        logger = ExternalApis::Logger.new
        http_client = ExternalApis::HttpClient.new(
          headers: config.http_headers,
          max_redirects: config.max_redirects,
          logger: logger,
          name: 'ROR'
        )
        client = Client.new(http_client: http_client, metadata_url: config.download_url, logger: logger)
        new(client: client, config: config, logger: logger)
      end

      def initialize(client:, config:, logger:, mapper: RecordMapper)
        @client = client
        @mapper = mapper
        @config = config
        @logger = logger
      end

      def call(force: false)
        force = ActiveModel::Type::Boolean.new.cast(force)
        context = "ROR sync (force: #{force})"

        logger.info('Starting ROR sync: checking Zenodo metadata')

        metadata = client.latest_dump_metadata
        if metadata.blank?
          logger.error(context: context, error: StandardError.new('Unable to fetch ROR metadata from Zenodo.'))
          return :failure
        end

        FileUtils.mkdir_p(config.file_dir)
        old_checksum_val = File.read(config.checksum_file) if File.exist?(config.checksum_file) && !force

        if old_checksum_val == metadata[:checksum]
          logger.info('No new ROR file to process; checksum matches the cached copy.')
          return :no_change
        end

        download_link = metadata.dig(:links, :download)
        download_file = metadata[:key].presence
        if download_link.blank? || download_file.blank?
          logger.error(context: context, error: StandardError.new('ROR metadata is missing a download link or archive key.'))
          return :failure
        end

        logger.info("New ROR file detected - checksum #{metadata[:checksum]}")
        logger.info("Stage: download - #{download_file}")
        logger.info("Source: #{download_link}")

        payload = client.download(download_link)
        if payload.blank?
          logger.error(context: context, error: StandardError.new('Unable to download ROR file.'))
          return :failure
        end

        File.binwrite(config.zip_file, payload)
        logger.info("Stage: save - downloaded archive written to #{config.zip_file}")

        json_file = "#{File.basename(download_file).delete_suffix('.zip')}.json"
        logger.info("Stage: populate - processing #{json_file} into the local ROR table")
        return :failure unless process_ror_file(zip_file: config.zip_file, file: json_file)

        logger.info("Stage: finalize - writing checksum #{metadata[:checksum]}")
        File.write(config.checksum_file, metadata[:checksum])
        logger.info('ROR sync completed successfully.')
        :success
      end

      private

      attr_reader :client, :mapper, :config, :logger

      def process_ror_file(zip_file:, file:)
        return false unless zip_file.present? && file.present?

        if unzip_file(zip_file: zip_file, destination: config.file_dir)
          if File.exist?("#{config.file_dir}/#{file}")
            json_file = File.open("#{config.file_dir}/#{file}", 'r')
            json = JSON.parse(json_file.read)
            total = json.length
            interval = progress_interval_for(total)

            logger.info("Stage: populate - starting record processing for #{total} records; progress updates every #{interval} records")

            json.each_with_index do |hash, index|
              current = index + 1
              logger.info("Progress: #{current}/#{total} records (#{percentage(current, total)}%)") if should_log_progress?(current, total, interval)

              hash = hash.with_indifferent_access if hash.is_a?(Hash)

              next if process_ror_record(record: hash, time: json_file.mtime)

              logger.warn("Unable to process record #{current}/#{total} for: '#{hash&.fetch('name', hash&.fetch('id', 'unknown'))}'")
            end

            logger.info("Stage: cleanup - removing stale records older than #{json_file.mtime.strftime('%Y-%m-%d %H:%M:%S')}")
            ::Ror.where('file_timestamp < ?', json_file.mtime).delete_all
            logger.info("Stage: complete - finished processing #{total} ROR records")
            true
          else
            logger.error(context: 'ROR import', error: StandardError.new('Unable to find JSON file in archive.'))
            false
          end
        else
          logger.error(context: 'ROR import', error: StandardError.new('Unable to unzip ROR archive.'))
          false
        end
      rescue JSON::ParserError => e
        logger.error(context: 'ROR import', error: e)
        false
      end

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

      def process_ror_record(record:, time:)
        attrs = mapper.call(record)
        return nil if attrs.blank? || attrs[:ror_id].blank?

        ror_model = ::Ror.find_or_create_by(ror_id: attrs[:ror_id])
        ror_model.assign_attributes(attrs.except(:ror_id).merge(file_timestamp: time))

        ror_model.save!
        true
      rescue StandardError => e
        record_id = record['id'] || record['ror_id'] || 'unknown'
        detail = "Record #{record_id} failed during ROR population: #{e.message}"
        logger.error(context: 'ROR import', error: StandardError.new(detail))
        logger.warn("Payload for failed record: #{record.to_s[0, 1000]}")
        false
      end

      def unzip_file(zip_file:, destination:)
        return false unless File.exist?(zip_file)

        destination = File.expand_path(destination.to_s)
        Zip::File.open(zip_file) do |zip|
          zip.each do |entry|
            next if entry.directory?

            output_file = File.expand_path(entry.name, destination)
            unless output_file.start_with?("#{destination}/")
              logger.error(context: 'ROR import', error: StandardError.new("Archive entry escapes import directory: #{entry.name}"))
              return false
            end

            FileUtils.mkdir_p(File.dirname(output_file))
            File.open(output_file, 'wb') do |output|
              entry.get_input_stream { |input| IO.copy_stream(input, output) }
            end
          end
        end
        true
      rescue Zip::Error, Errno::ENOENT => e
        logger.error(context: 'ROR import', error: e)
        false
      end
    end
  end
end
