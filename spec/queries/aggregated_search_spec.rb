# frozen_string_literal: true

require "rails_helper"

RSpec.describe AggregatedSearch, type: :model do
  describe ".institution_search" do
    it "prefers institution records when a ROR is shared, while still keeping unmatched RORs" do
      country = create(:country, name: "United States")
      shared_ror = create(:ror, name: "University of California")
      matching_institution = create(:institution, name: "University of California", city: "Oakland", country: country, ror: shared_ror)
      unmatched_ror = create(:ror, name: "California State University")

      result = described_class.institution_search("california")

      expect(result.map { |item| item[:type] }).to include(:institution)
      expect(result.map { |item| item[:name] }).to include(matching_institution.name)
      expect(result).not_to include(include(type: :ror, id: shared_ror.ror_id))
      expect(result).to include(include(type: :ror, id: unmatched_ror.ror_id, name: unmatched_ror.name))
    end
  end
end
