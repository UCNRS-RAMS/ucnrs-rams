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

        download_link = metadata.fetch(:links, {})[:download]
        download_file = metadata[:key].presence || File.basename(download_link.to_s)
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

        json_file = download_file.split('/').last.gsub('.zip', '')
        json_file = "#{json_file}.json" unless json_file.end_with?('.json')

        log_message(method: method, message: "Stage: populate - processing #{json_file} into the local ROR table")
        return :failure unless process_ror_file(zip_file: zip_file, file: json_file)

        log_message(method: method, message: "Stage: finalize - writing checksum #{metadata[:checksum]}")
        File.write(checksum_file, metadata[:checksum])
        log_message(method: method, message: 'ROR sync completed successfully.')
        :success
      end
      # rubocop:enable Metrics/AbcSize
            private

      # Fetch the latest Zenodo metadata for ROR files
      # rubocop:disable Metrics/AbcSize
      def fetch_zenodo_metadata
        Rails.logger.error 'No :download_url defined for RorService!' if download_url.blank?
        return nil if download_url.blank?

        # Fetch the latest ROR metadata from Zenodo (the query will place the most recent
        # version 1st)
        resp = http_get(uri: download_url, additional_headers: { host: 'zenodo.org' }, debug: false)

        unless resp.present? && resp.status == 200
          handle_http_failure(method: 'Fetching ROR metadata from Zenodo', http_response: resp)
          notify_administrators(obj: 'RorService', response: resp)
          return nil
        end
        json = JSON.parse(resp.body)

        # Extract the most recent file's metadata
        file_metadata = json.fetch('hits', {}).fetch('hits', []).first&.fetch('files', [])&.last&.with_indifferent_access
        if file_metadata.blank?
          handle_http_failure(method: 'No file found in ROR metadata from Zenodo', http_response: resp)
          notify_administrators(obj: 'RorService', response: resp)
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

        headers = {
          host: 'zenodo.org',
          Accept: 'application/json',
          'Content-Type': 'application/json',
          'User-Agent': "California Digital Library - dmptool.org (mailto:dmptool@ucop.edu)"
        }

        resp = http_get(uri: url, additional_headers: headers, debug: false)

        unless resp.present? && resp.status == 200
          handle_http_failure(method: "Fetching ROR file from Zenodo - #{url}", http_response: resp)
          notify_administrators(obj: 'RorService', response: resp)
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

            log_message(method: method, message: "Stage: cleanup - removing stale records older than #{json_file.mtime.strftime('%Y-%m-%d %H:%M:%S')}")
            Ror.where('file_timestamp < ?', json_file.mtime.strftime('%Y-%m-%d %H:%M:%S')).destroy_all
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
      # rubocop:enable Metrics/AbcSize
            # Transfer the contents of a ROR record to the local rors table
      # rubocop:disable Metrics/AbcSize
      def process_ror_record(record:, time:)
        return nil unless record.present? && record.is_a?(Hash) && record['id'].present?

        ror_model = Ror.find_or_create_by(ror_id: record['id'])
        ror_model.name = safe_string(value: org_name(item: record))
        ror_model.acronyms = ror_acronyms(item: record)
        ror_model.aliases = ror_aliases(item: record)
        ror_model.country = country_data(item: record)
        ror_model.types = record['types'] || []
        ror_model.language = org_language(item: record)
        ror_model.file_timestamp = time.strftime('%Y-%m-%d %H:%M:%S')
        ror_model.fundref_id = fundref_id(item: record)
        ror_model.home_page = safe_string(value: primary_website(item: record))

        ror_model.save!
        true
      rescue StandardError => e
        record_id = record['id'] || record['ror_id'] || 'unknown'
        detail = "Record #{record_id} failed during ROR population: #{e.message}"
        log_error(method: 'ExternalApis::RorService.process_ror_record', error: StandardError.new(detail))
        log_message(method: 'ExternalApis::RorService.process_ror_record', message: "Payload for failed record: #{record.to_s[0, 1000]}", info: false)
        false
      end
      # rubocop:enable Metrics/AbcSize

      def safe_string(value:)
        return value if value.blank? || value.length < 255

        value[0..254]
      end

      def ror_names(item:, type:)
        return [] unless item.present? && item['names'].is_a?(Array)

        item['names'].filter_map do |name|
          next unless name.is_a?(Hash)

          types = Array(name['types'])
          next unless types.any?
          next unless types.map(&:to_s).include?(type.to_s)

          name['value'].presence
        end
      end

      def ror_acronyms(item:)
        ror_names(item: item, type: 'acronym')
      end

      def ror_aliases(item:)
        ror_names(item: item, type: 'alias')
      end

      def country_data(item:)
        return item['country'] if item.present? && item['country'].is_a?(Hash) && item['country'].present?

        return {} if item.blank?

        geonames = Array(item['locations']).first&.[]('geonames_details')
        return {} if geonames.blank?

        {
          'country_name' => geonames['country_name'],
          'country_code' => geonames['country_code']
        }
      end

      # Org names are not unique, so include the Org URL if available or
      # the country. For example:
      #    "Example College (example.edu)"
      #    "Example College (Brazil)"
      # rubocop:disable Metrics/AbcSize
      def org_name(item:)
        return '' if item.blank?

        legacy_name = item['name']
        return legacy_name if legacy_name.present? && item['links'].blank? && item['country'].blank? && item['names'].blank?

        candidate_name = preferred_ror_name(item) || item['name']
        candidate_name = candidate_name.to_s.strip
        return '' if candidate_name.blank?

        country_name = country_name_for(item)
        website = org_website(item: item)
        return candidate_name unless website.present? || country_name.present?

        "#{candidate_name} (#{website || country_name})"
      end
      # rubocop:enable Metrics/AbcSize

      def preferred_ror_name(item)
        return nil unless item['names'].is_a?(Array)

        item['names'].find { |name| name.is_a?(Hash) && Array(name['types']).include?('ror_display') } ||
          item['names'].find { |name| name.is_a?(Hash) && Array(name['types']).include?('label') }
      end

      def country_name_for(item)
        country = country_data(item: item)
        country.is_a?(Hash) ? country['country_name'].to_s : ''
      end

      # Extracts the org's ISO639 if available
      def org_language(item:)
        dflt = I18n.default_locale || 'en'
        return dflt if item.blank?

        country = country_code_for(item)
        return 'en' if country == 'US'

        lang = lang_from_names(item)
        return lang if lang.present?

        legacy_labels = item.fetch('labels', [])
        return legacy_labels.first&.[]('iso639') || dflt if legacy_labels.is_a?(Array) && legacy_labels.first.present?

        dflt
      end

      def country_code_for(item)
        loc = Array(item['locations']).first&.[]('geonames_details')
        return loc['country_code'] if loc.present? && loc['country_code'].present?

        item.dig('country', 'country_code')
      end

      def lang_from_names(item)
        names = Array(item['names'])
        names.find { |name| name.is_a?(Hash) && name['lang'].present? }&.[]('lang')
      end

      # Extracts the website URL from the item
      def primary_website(item:)
        return nil if item.blank?

        links = item['links']
        return website_from_links(links) if links.is_a?(Array)

        links
      end

      # rubocop:disable Metrics/AbcSize
      def website_from_links(links)
        website = links.find { |link| link.is_a?(Hash) && link['type'].to_s == 'website' && link['value'].present? }
        return website['value'] if website.present?

        first_link = links.find { |link| link.is_a?(Hash) && link['value'].present? }
        return first_link['value'] if first_link.present?

        string_link = links.find { |link| link.is_a?(String) && link.present? }
        return string_link if string_link.present?

        return links.first if links.first.is_a?(String) && links.first.present?

        nil
      end
      # rubocop:enable Metrics/AbcSize

      # Extracts the website domain from the item for contextual names
      def org_website(item:)
        website = primary_website(item: item)
        return nil if website.blank?

        domain = extract_domain(website.to_s)
        return nil if domain.blank?

        domain.gsub('www.', '')
      end

      def extract_domain(website)
        domain_regex = %r{^(?:http://|www\.|https://)([^/]+)}
        website.scan(domain_regex).last&.first
      end

      # Extracts the FundRef Id if available
      def fundref_id(item:)
        return '' if item.blank?

        external_ids = item['external_ids']
        return fundref_id_from_hash(external_ids) if external_ids.is_a?(Hash)

        fundref = find_fundref_entry(external_ids)
        return '' if fundref.blank?

        preferred_or_first(fundref)
      end

      def fundref_id_from_hash(external_ids)
        fundref = external_ids['FundRef'] || external_ids['fundref']
        return '' if fundref.blank?

        preferred_or_first(fundref)
      end

      def preferred_or_first(item)
        preferred = item['preferred']
        return preferred.to_s if preferred.present?

        Array(item['all']).first.to_s
      end

      def find_fundref_entry(external_ids)
        Array(external_ids).find do |id_info|
          id_info.is_a?(Hash) && id_info['type'].to_s.casecmp('fundref').zero?
        end
      end
    end
  end
end
