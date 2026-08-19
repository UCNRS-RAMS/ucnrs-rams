require "rails_helper"

RSpec.describe Ror, type: :model do
  describe "associations" do
    it "finds institutions by matching ror_id" do
      ror = create(:ror)
      matching_institution = create(:institution, ror_id: ror.ror_id)
      create(:institution, ror_id: "https://ror.org/other")

      expect(ror.institutions).to contain_exactly(matching_institution)
    end
  end
end
