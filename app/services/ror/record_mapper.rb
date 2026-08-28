# frozen_string_literal: true

class Ror::RecordMapper
  class << self
    # Maps a ROR API record into attributes for the local Ror model.
    def call(record)
      return {} unless record.present? && record.is_a?(Hash) && record['id'].present?

      {
        ror_id: record['id'],
        name: safe_string(value: org_name(item: record)),
        acronyms: ror_acronyms(item: record),
        aliases: ror_aliases(item: record),
        country: country_data(item: record),
        types: record['types'] || [],
        language: org_language(item: record),
        fundref_id: fundref_id(item: record),
        home_page: safe_string(value: primary_website(item: record))
      }
    end

    private

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
      return nil unless item.is_a?(Hash)

      names = Array(item['names'])
      names.find { |name| name_type?(name, 'ror_display') }&.[]('value') ||
        names.find { |name| name_type?(name, 'label') }&.[]('value')
    end

    def name_type?(name, type)
      name.is_a?(Hash) && Array(name['types']).include?(type)
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

      # this is for an older style of ROR record that has a 'labels' array with an 'iso639' key
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
