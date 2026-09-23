# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ror, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:institutions).with_primary_key(:ror_id).inverse_of(:ror).dependent(:nullify) }

    it "finds institutions by matching ror_id" do
      ror = create(:ror)
      matching_institution = create(:institution, ror_id: ror.ror_id)
      create(:institution, ror_id: "https://ror.org/other")

      expect(ror.institutions).to contain_exactly(matching_institution)
    end
  end

  describe "scopes" do
    let(:match) { create(:ror) }
    let(:not_match) { create(:ror) }
    let(:term) { "example-search-term" }

    before do
      match.update!(name: "Example University")
      not_match.update!(name: "Other University")
    end

    it ".by_acronym returns the matching records" do
      match.update!(acronyms: match.acronyms + [term])
      not_match.update!(acronyms: [])

      expect(described_class.by_acronym(term)).to contain_exactly(match)
    end

    it ".by_acronym is case-insensitive and escapes wildcard characters" do
      literal_term = "RoR%_Test"
      match.update!(acronyms: [literal_term])
      not_match.update!(acronyms: ["RoR_Test"])

      expect(described_class.by_acronym(literal_term.upcase)).to contain_exactly(match)
    end

    it ".by_alias returns the matching records" do
      match.update!(aliases: match.aliases + [term])
      not_match.update!(aliases: [])

      expect(described_class.by_alias(term)).to contain_exactly(match)
    end

    it ".by_type returns the matching records" do
      match.update!(types: match.types + [term])
      not_match.update!(types: [])

      expect(described_class.by_type(term)).to contain_exactly(match)
    end

    it ".by_name returns the matching records" do
      match.update!(name: "#{match.name} (#{term})")
      not_match.update!(name: "Other University")

      expect(described_class.by_name(term)).to contain_exactly(match)
    end

    it ".by_domain returns the matching records" do
      match.update!(home_page: "https://#{term}.edu")
      not_match.update!(home_page: "https://example.org")

      expect(described_class.by_domain(term)).to contain_exactly(match)
    end

    it ".search tokenizes and partially matches the name, alias, and acronym fields" do
      match.update!(
        name: "University of California, Davis",
        aliases: ["UC Davis"],
        acronyms: ["UCD"]
      )
      not_match.update!(
        name: "Stanford University",
        aliases: ["SU"],
        acronyms: ["SU"]
      )

      expect(described_class.search("uc davis")).to contain_exactly(match)
      expect(described_class.search("davis")).to contain_exactly(match)
      expect(described_class.search("UCD")).to contain_exactly(match)
    end

    it ".search accepts a limit keyword to cap the number of matching records" do
      create_list(:ror, 3, name: "Research University")

      expect(described_class.search("Research University", limit: 2).count).to eq(2)
    end

    it ".search loads the rors.sql fixture and returns records for a full-word match" do
      fixture_sql = Rails.root.join("spec/fixtures/rors.sql").read
      ActiveRecord::Base.connection.execute(fixture_sql)

      results = described_class.search("London")

      expect(results.map(&:name)).to include(
        "Transport for London (tfl.gov.uk)",
        "London Borough of Camden (camden.gov.uk)",
        "London School of Economics and Political Science (lse.ac.uk)"
      )
    end

    it ".search loads the rors.sql fixture and matches San/Fran and UCLA variants" do
      fixture_sql = Rails.root.join("spec/fixtures/rors.sql").read
      ActiveRecord::Base.connection.execute(fixture_sql)

      expect(described_class.search("San").map(&:name)).to include("University of California, San Francisco (ucsf.edu)")
      expect(described_class.search("San").map(&:name)).to include("University of California San Diego (ucsd.edu)")
      expect(described_class.search("Fran").map(&:name)).to include("University of California, San Francisco (ucsf.edu)")
      expect(described_class.search("San Fran").map(&:name)).to include("University of California, San Francisco (ucsf.edu)")
      expect(described_class.search("San Fran").map(&:name)).not_to include("University of California San Diego (ucsd.edu)")
      expect(described_class.search("UCLA").map(&:name)).to include("University of California, Los Angeles (ucla.edu)")
    end
  end

  describe ".from_email_domain" do
    it "returns nil when no email domain is provided" do
      expect(described_class.from_email_domain(email_domain: nil)).to be_nil
    end

    it "returns nil when no matching ROR record is found" do
      expect(described_class.from_email_domain(email_domain: "foo.bar")).to be_nil
    end

    it "returns the closest matching ROR record" do
      preferred = create(:ror, home_page: "https://foo.edu")

      expect(described_class.from_email_domain(email_domain: "foo.edu")).to eq(preferred)
      expect(described_class.from_email_domain(email_domain: "sub.foo.edu")).to be_nil
      expect(described_class.from_email_domain(email_domain: "foo.bar.edu")).to be_nil
      expect(described_class.from_email_domain(email_domain: "nofoo.edu")).to be_nil
      expect(described_class.from_email_domain(email_domain: "no-foo.edu")).to be_nil

      preferred.update!(home_page: "https://medical-center.foo.edu")

      expect(described_class.from_email_domain(email_domain: "foo.edu")).to eq(preferred)
      expect(described_class.from_email_domain(email_domain: "FOO.EDU")).to eq(preferred)
      expect(described_class.from_email_domain(email_domain: "medical-center.foo.edu")).to eq(preferred)
    end
  end
end
