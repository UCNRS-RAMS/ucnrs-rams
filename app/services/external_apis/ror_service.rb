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
        Rails.configuration.x.ror&.full_catalog_file
      end

      def file_dir
        Rails.configuration.x.ror&.file_dir
      end

      def checksum_file
        Rails.configuration.x.ror&.checksum_file
      end

      def zip_file
        Rails.configuration.x.ror&.zip_file
      end

      def active?
        Rails.configuration.x.ror&.active || super
      end

      def heartbeat_path
        Rails.configuration.x.ror&.heartbeat_path
      end

      def search_path
        Rails.configuration.x.ror&.search_path
      end

      def fetch(force: false)
        method = "ExternalApis::RorService.fetch(force: #{force})"

        # Fetch the Zenodo metadata for ROR to see if we have the latest data dump
        metadata = fetch_zenodo_metadata
        return :failure if metadata.blank?

        FileUtils.mkdir_p(file_dir)

        # this is just to cache the last downloaded checksum to a file (if it persists)
        checksum = File.open(checksum_file, 'w+') unless File.exist?(checksum_file) && !force
        checksum = File.open(checksum_file, 'r+') if checksum.blank?
        old_checksum_val = checksum.read

        if old_checksum_val == metadata[:checksum]
          log_message(method: method, message: 'There is no new ROR file to process.')
          return :no_change
        end

        download_file = metadata.fetch(:links, {})[:download]
        log_message(method: method, message: "New ROR file detected - checksum #{metadata[:checksum]}")
        log_message(method: method, message: "Downloading #{download_file}")

        payload = download_ror_file(url: download_file)
        return :failure if payload.blank?

        file = File.open(zip_file, 'wb')
        file.write(payload)

        unless validate_downloaded_file(file_path: zip_file, checksum: metadata[:checksum])
          log_error(method: method, error: StandardError.new('Downloaded ROR zip does not match checksum!'))
          return :failure
        end

        json_file = json_file_name_from_zip(zip_file: zip_file)
        return :failure if json_file.blank?

        # Process the ROR JSON
        return :failure unless process_ror_file(zip_file: zip_file, file: json_file)

        checksum = File.open(checksum_file, 'w')
        checksum.write(metadata[:checksum])
        :success
      end

      private

      # Fetch the latest Zenodo metadata for ROR files
      def fetch_zenodo_metadata
        Rails.logger.error 'No :download_url defined for RorService!' if download_url.blank?
        return nil if download_url.blank?

        # Fetch the latest ROR metadata from Zenodo (the query will place the most recent
        # version 1st)
        resp = http_get(uri: download_url, additional_headers: { host: 'zenodo.org' }, debug: false)
        unless resp.present? && resp.code == 200
          handle_http_failure(method: 'Fetching ROR metadata from Zenodo', http_response: resp)
          notify_administrators(obj: 'RorService', response: resp)
          ret urn nil
        end
        json = JSON.parse(resp.body)

        # Zenodo search results contain records under hits.hits.
        records = json.dig('hits', 'hits')
        record = records.first if records.is_a?(Array)
        files = record.fetch('files', []) if record.is_a?(Hash)
        file_metadata = files.first&.with_indifferent_access if files.is_a?(Array)
        if file_metadata.present? && file_metadata[:links].is_a?(Hash)
          file_metadata[:links][:download] ||= file_metadata[:links][:self]
        end
        unless file_metadata.present? && file_metadata.fetch(:links, {})[:download].present?
          handle_http_failure(method: 'No file found in ROR metadata from Zenodo', http_response: resp)
          notify_administrators(obj: 'RorService', response: resp)
          return nil
        end

        file_metadata
      rescue JSON::ParserError => e
        log_error(method: 'RorService', error: e)
        nil
      end

      # Download the latest ROR data
      def download_ror_file(url:)
        return nil if url.blank?

        headers = {
          host: 'zenodo.org',
          Accept: 'application/json'
        }
        resp = http_get(uri: url, additional_headers: headers, debug: false)
        unless resp.present? && resp.code == 200
          handle_http_failure(method: "Fetching ROR file from Zenodo - #{url}", http_response: resp)
          notify_administrators(obj: 'RorService', response: resp)
          return nil
        end
        resp.body
      end

      def json_file_name_from_zip(zip_file:)
        return nil unless zip_file.present? && File.exist?(zip_file)

        Zip::File.open(zip_file) do |zip|
          zip.each do |entry|
            next if entry.name.to_s.end_with?('/')
            return entry.name.split('/').last if entry.name.to_s.end_with?('.json')
          end
        end

        nil
      end

      # Parse the JSON file and process each individual record
      def process_ror_file(zip_file:, file:)
        return false unless zip_file.present? && file.present?

        if unzip_file(zip_file: zip_file, destination: file_dir)
          method = 'ExternalApis::RorService.process_ror-file'
          json_path = File.join(file_dir.to_s, file)
          if File.exist?(json_path)
            json_file = File.open(json_path, 'r')
            json = JSON.parse(json_file.read)
            cntr = 0
            total = json.length
            json.each do |hash|
              cntr += 1
              log_message(method: method, message: "Processed #{cntr} out of #{total} records") if (cntr % 1000).zero?

              hash = hash.with_indifferent_access if hash.is_a?(Hash)

              next if process_ror_record(record: hash, time: json_file.mtime)

              log_message(
                method: method,
                message: "Unable to process record for: '#{hash&.fetch('name', 'unknown')}'",
                info: false
              )
            end
            # Remove any old ROR records (their file_timestamps would not have been updated)
            Ror.where('file_timestamp < ?', json_file.mtime.strftime('%Y-%m-%d %H:%M:%S')).destroy_all
            true
          else
            log_error(method: method, error: StandardError.new("Unable to find json in zip: #{json_path}"))
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

      # Transfer the contents of the JSON record to the rors table
      def process_ror_record(record:, time:)
        return nil unless record.present? && record.is_a?(Hash) && record['id'].present?

        ror = Ror.find_or_create_by(ror_id: record['id'])
        ror.name = safe_string(value: org_name(item: record))
        ror.acronyms = extract_names_by_type(item: record, type: 'acronym')
        ror.aliases = extract_names_by_type(item: record, type: 'alias')
        ror.country = country_name(item: record)
        ror.types = record['types']
        ror.language = org_language(item: record)
        ror.file_timestamp = time.strftime('%Y-%m-%d %H:%M:%S')
        ror.fundref_id = fundref_id(item: record)
        ror.home_page = safe_string(value: org_website(item: record))
        ror.save
        true
      rescue StandardError => e
        log_error(method: 'ExternalApis::RorService.process_ror_record', error: e)
        log_message(method: 'ExternalApis::RorService.process_ror-record', message: record.to_s)
        false
      end

      def safe_string(value:)
        return value if value.blank? || value.is_a?(String) && value.length < 255
        return value.to_s if value.is_a?(Hash) && value['value'].present?
        return value['value'] if value.is_a?(Hash) && value['value'].present?

        string_value = value.to_s
        return string_value if string_value.length < 255

        string_value[0..254]
      end

      def extract_names_by_type(item:, type:)
        return [] unless item.present? && item['names'].is_a?(Array)

        item['names'].filter_map do |entry|
          next unless entry.is_a?(Hash)
          next unless Array(entry['types']).include?(type.to_s)

          entry['value']
        end
      end

      def country_name(item:)
        country = item.dig('country', 'country_name')
        return country if country.present?

        item.dig('locations', 0, 'geonames_details', 'country_name')
      end

      # Org names are not unique, so include the Org URL if available or
      # the country. For example:
      #    "Example College (example.edu)"
      #    "Example College (Brazil)"
      def org_name(item:)
        return '' unless item.present?

        candidate_name = item['name'] || first_named_value(item: item)
        return '' if candidate_name.blank?

        country = country_name(item: item)
        website = org_website(item: item)
        return candidate_name unless website.present? || country.present?

        "#{candidate_name} (#{website || country})"
      end

      def first_named_value(item:)
        return nil unless item.present? && item['names'].is_a?(Array)

        preferred = item['names'].find { |name| name.is_a?(Hash) && Array(name['types']).include?('ror_display') }
        preferred ||= item['names'].find { |name| name.is_a?(Hash) && Array(name['types']).include?('label') }
        preferred ||= item['names'].first
        preferred.is_a?(Hash) ? preferred['value'] : preferred
      end

      # Extracts the org's ISO639 if available
      def org_language(item:)
        dflt = I18n.default_locale || 'en'
        return dflt if item.blank?

        name_entry = item['names']&.find do |candidate|
          candidate.is_a?(Hash) && Array(candidate['types']).include?('ror_display')
        end
        name_entry ||= item['names']&.find { |candidate| candidate.is_a?(Hash) && candidate['lang'].present? }
        language = name_entry&.fetch('lang', nil)
        return language if language.present?

        country_code = item.dig('country', 'country_code') || item.dig('locations', 0, 'geonames_details', 'country_code')
        return 'en' if country_code == 'US'

        dflt
      end

      # Extracts the website domain from the item
      def org_website(item:)
        return nil unless item.present?

        links = Array(item['links'])
        website_link = links.find { |link| link.is_a?(Hash) && link['type'] == 'website' }
        website = website_link.present? ? website_link['value'] : links.first
        return nil if website.blank?

        website.to_s
      end

      # Extracts the FundRef Id if available
      def fundref_id(item:)
        return '' unless item.present? && item['external_ids'].is_a?(Array)

        external_id = item['external_ids'].find { |entry| entry.is_a?(Hash) && entry['type'].to_s.casecmp('FundRef').zero? }
        return '' if external_id.blank?

        preferred = external_id['preferred']
        return preferred if preferred.present?

        Array(external_id['all']).first
      end
    end
  end
end
