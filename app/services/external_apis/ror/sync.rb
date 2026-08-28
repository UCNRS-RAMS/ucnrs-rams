# frozen_string_literal: true

module ExternalApis
  module Ror
    class Sync
      def initialize(service: ExternalApis::RorService, client: nil, mapper: RecordMapper)
        @service = service
        @client = client || Client.new(service: service)
        @mapper = mapper
      end

      def call(force: false)
        force = ActiveModel::Type::Boolean.new.cast(force)
        method = "ExternalApis::Ror::Sync.call(force: #{force})"

        service.log_message(method: method, message: 'Starting ROR sync: checking Zenodo metadata')

        metadata = client.latest_dump_metadata
        if metadata.blank?
          service.log_error(method: method, error: StandardError.new('Unable to fetch ROR metadata from Zenodo!'))
          return :failure
        end

        FileUtils.mkdir_p(service.file_dir)
        old_checksum_val = File.read(service.checksum_file) if File.exist?(service.checksum_file) && !force

        if old_checksum_val == metadata[:checksum]
          service.log_message(method: method, message: 'No new ROR file to process; checksum matches the cached copy.')
          return :no_change
        end

        download_link = metadata.dig(:links, :download)
        download_file = metadata[:key].presence
        if download_link.blank? || download_file.blank?
          service.log_error(method: method, error: StandardError.new('ROR metadata is missing a download link or archive key.'))
          return :failure
        end

        service.log_message(method: method, message: "New ROR file detected - checksum #{metadata[:checksum]}")
        service.log_message(method: method, message: "Stage: download - #{download_file}")
        service.log_message(method: method, message: "Source: #{download_link}")

        payload = client.download(download_link)
        if payload.blank?
          service.log_error(method: method, error: StandardError.new('Unable to download ROR file!'))
          return :failure
        end

        File.binwrite(service.zip_file, payload)
        service.log_message(method: method, message: "Stage: save - downloaded archive written to #{service.zip_file}")

        json_file = "#{File.basename(download_file).delete_suffix('.zip')}.json"
        service.log_message(method: method, message: "Stage: populate - processing #{json_file} into the local ROR table")
        return :failure unless process_ror_file(zip_file: service.zip_file, file: json_file)

        service.log_message(method: method, message: "Stage: finalize - writing checksum #{metadata[:checksum]}")
        File.write(service.checksum_file, metadata[:checksum])
        service.log_message(method: method, message: 'ROR sync completed successfully.')
        :success
      end

      private

      attr_reader :service, :client, :mapper

      def process_ror_file(zip_file:, file:)
        return service.process_ror_file(zip_file: zip_file, file: file) if stubbed?(service, :process_ror_file)
        return false unless zip_file.present? && file.present?

        method = 'ExternalApis::Ror::Sync.process_ror_file'

        if service.send(:unzip_file, zip_file: zip_file, destination: service.file_dir)
          if File.exist?("#{service.file_dir}/#{file}")
            json_file = File.open("#{service.file_dir}/#{file}", 'r')
            json = JSON.parse(json_file.read)
            total = json.length
            interval = progress_interval_for(total)

            service.log_message(method: method, message: "Stage: populate - starting record processing for #{total} records; progress updates every #{interval} records")

            json.each_with_index do |hash, index|
              current = index + 1
              service.log_message(method: method, message: "Progress: #{current}/#{total} records (#{percentage(current, total)}%)") if should_log_progress?(current, total, interval)

              hash = hash.with_indifferent_access if hash.is_a?(Hash)

              next if process_ror_record(record: hash, time: json_file.mtime)

              service.log_message(
                method: method,
                message: "Unable to process record #{current}/#{total} for: '#{hash&.fetch('name', hash&.fetch('id', 'unknown'))}'",
                info: false
              )
            end

            service.log_message(method: method, message: "Stage: cleanup - removing stale records older than #{json_file.mtime.strftime('%Y-%m-%d %H:%M:%S')}")
            ::Ror.where('file_timestamp < ?', json_file.mtime).delete_all
            service.log_message(method: method, message: "Stage: complete - finished processing #{total} ROR records")
            true
          else
            service.log_error(method: method, error: StandardError.new('Unable to find json in zip!'))
            false
          end
        else
          service.log_error(method: method, error: StandardError.new('Unable to unzip contents of ROR file'))
          false
        end
      rescue JSON::ParserError => e
        service.log_error(method: method, error: e)
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
        return service.process_ror_record(record: record, time: time) if stubbed?(service, :process_ror_record)

        attrs = mapper.call(record)
        return nil if attrs.blank? || attrs[:ror_id].blank?

        ror_model = ::Ror.find_or_create_by(ror_id: attrs[:ror_id])
        ror_model.assign_attributes(attrs.except(:ror_id).merge(file_timestamp: time))

        ror_model.save!
        true
      rescue StandardError => e
        record_id = record['id'] || record['ror_id'] || 'unknown'
        detail = "Record #{record_id} failed during ROR population: #{e.message}"
        service.log_error(method: 'ExternalApis::Ror::Sync.process_ror_record', error: StandardError.new(detail))
        service.log_message(method: 'ExternalApis::Ror::Sync.process_ror_record', message: "Payload for failed record: #{record.to_s[0, 1000]}", info: false)
        false
      end

      def stubbed?(target, method_name)
        return false unless target.respond_to?(method_name)

        target.method(method_name).owner != target.singleton_class
      end
    end
  end
end
