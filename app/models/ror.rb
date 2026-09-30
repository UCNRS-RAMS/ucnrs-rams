# frozen_string_literal: true

# Local cache of Research Organization Registry (ROR) records.
# See https://ror.org
class Ror < ApplicationRecord
  before_validation :update_searchable_text

  has_many :institutions, primary_key: :ror_id, inverse_of: :ror, dependent: :nullify

  def cities
    location_values("name")
  end

  def country_codes
    location_values("country_code")
  end

  def continent_codes
    location_values("continent_code")
  end

  def state_codes
    location_values("country_subdivision_code")
  end

  # ==========
  # = Scopes =
  # ==========

  scope :by_acronym, lambda { |term|
    where(safe_json_lower_where_clause(table: 'rors', attribute: 'acronyms'), json_like_pattern(term))
  }

  scope :by_alias, lambda { |term|
    where(safe_json_lower_where_clause(table: 'rors', attribute: 'aliases'), json_like_pattern(term))
  }

  scope :by_name, lambda { |term|
    where('LOWER(rors.name) LIKE ?', like_pattern(term))
  }

  scope :by_type, lambda { |term|
    where(safe_json_lower_where_clause(table: 'rors', attribute: 'types'), json_like_pattern(term))
  }

  scope :by_domain, lambda { |term|
    where('LOWER(rors.home_page) LIKE ?', like_pattern(term))
  }

  def self.search(query, limit: nil)
    found_rors = all
    return found_rors.limit(limit) if query.blank? && limit.present?

    tokenize(query).each do |partial|
      terms = partial.scan(/[\p{Alnum}]+/)
      return found_rors.none if terms.empty?

      terms.each do |term|
        found_rors = found_rors.where(
          "MATCH(rors.searchable_text) AGAINST (? IN BOOLEAN MODE)",
          full_text_prefix(term.downcase)
        )
      end
    end

    if query.present? && limit.present?
      # Rank the most relevant matches (exact acronym/name matches, then name
      # prefixes and exact aliases, then everything else) ahead of the rest
      # so that a `limit` cuts off the least relevant records instead of an
      # arbitrary/alphabetical slice that can drop a well-known match.
      # Callers that don't cap results with `limit` keep their existing order.
      found_rors = found_rors.order(Arel.sql(relevance_order_sql(query))).order(:name)
    end
    found_rors = found_rors.limit(limit) if limit.present?
    found_rors
  end

  def self.relevance_order_sql(query)
    normalized = query.to_s.downcase.strip
    exact_json_pattern = json_like_pattern(normalized)

    sanitize_sql_array([
      <<~SQL.squish,
        CASE
          WHEN LOWER(CAST(rors.acronyms AS CHAR)) LIKE ? THEN 0
          WHEN LOWER(rors.name) = ? THEN 0
          WHEN LOWER(rors.name) LIKE ? THEN 1
          WHEN LOWER(CAST(rors.aliases AS CHAR)) LIKE ? THEN 1
          WHEN LOWER(rors.name) LIKE ? THEN 2
          ELSE 3
        END
      SQL
      exact_json_pattern,
      normalized,
      "#{sanitize_sql_like(normalized)}%",
      exact_json_pattern,
      like_pattern(normalized)
    ])
  end
  private_class_method :relevance_order_sql

  def self.like_pattern(term)
    "%#{sanitize_sql_like(term.to_s.downcase)}%"
  end

  def self.json_like_pattern(term)
    "%\"#{sanitize_sql_like(term.to_s.downcase)}\"%"
  end

  def self.tokenize(query)
    URI.decode_www_form_component(query.to_s).strip.split
  end
  private_class_method :tokenize

  def self.full_text_prefix(term)
    "+#{term}*"
  end
  private_class_method :full_text_prefix

  # Get the Ror entry with the closest matching domain for the email domain
  def self.from_email_domain(email_domain:)
    return nil if email_domain.blank?

    domain = email_domain.downcase
    rors = where('LOWER(home_page) LIKE ? OR LOWER(home_page) LIKE ?', "%//#{domain}%", "%.#{domain}%")
    return nil unless rors.any?

    # Get the one with closest match (e.g. http://ucsd.edu instead of
    # http://health.ucsd.edu if the email_domain is 'ucsd.edu')
    rors.sort do |a, b|
      l = email_domain.length
      (domain_for(url: a.home_page).length - l) <=> (domain_for(url: b.home_page).length - l)
    end.first
  end


  def self.domain_for(url:)
    return '' if url.blank?

    url.downcase.gsub(%r{^(?:http://|https://|www\.)+}, '').split('/').first.to_s
  end

  private

  def update_searchable_text
    self.searchable_text = [ name, *Array(aliases), *Array(acronyms) ].compact.join(" ").downcase
  end

  def location_values(attribute)
    Array(locations).filter_map do |location|
      next unless location.is_a?(Hash) && location["geonames_details"].is_a?(Hash)

      location.dig("geonames_details", attribute).presence
    end
  end
end
