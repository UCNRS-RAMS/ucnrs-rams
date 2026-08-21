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

    it ".search combines the name, acronym, and alias scopes" do
      stubbed = described_class.all
      allow(described_class).to receive(:by_name).with(term).and_return(stubbed)
      allow(described_class).to receive(:by_acronym).with(term).and_return(stubbed)
      allow(described_class).to receive(:by_alias).with(term).and_return(stubbed)

      described_class.search(term)

      expect(described_class).to have_received(:by_name).with(term)
      expect(described_class).to have_received(:by_acronym).with(term)
      expect(described_class).to have_received(:by_alias).with(term)
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
