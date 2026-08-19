# frozen_string_literal: true

# Local cache of Research Organization Registry (ROR) records.
# See https://ror.org
class Ror < ApplicationRecord
  has_many :institutions, primary_key: :ror_id, foreign_key: :ror_id, inverse_of: :ror

  # ==========
  # = Scopes =
  # ==========

  scope :by_acronym, lambda { |term|
    where(safe_json_lower_where_clause(table: 'rors', attribute: 'acronyms'),
          "%\"#{term}\"%")
  }

  scope :by_alias, lambda { |term|
    where(safe_json_lower_where_clause(table: 'rors', attribute: 'aliases'),
          "%\"#{term}\"%")
  }

  scope :by_name, lambda { |term|
    where('LOWER(rors.name) LIKE LOWER(?)', "%#{term}%")
  }

  scope :by_type, lambda { |term|
    where(safe_json_lower_where_clause(table: 'rors', attribute: 'types'),
          "%\"#{term}\"%")
  }

  scope :by_domain, lambda { |term|
    where('LOWER(rors.home_page) LIKE LOWER(?)', "%#{term}%")
  }

  scope :search, lambda { |term|
    by_name(term).or(by_acronym(term)).or(by_alias(term))
  }

  # =================
  # = Class methods =
  # =================
  class << self
    # Get the Ror entry with the closest matching domain for the email domain
    def from_email_domain(email_domain:)
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

    private

    def domain_for(url:)
      return '' if url.blank?

      url.downcase.gsub(%r{^(?:http://|https://|www\.)+}, '').split('/').first.to_s
    end
  end
end
