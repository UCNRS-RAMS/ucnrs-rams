require "rails_helper"

RSpec.describe InstitutionsIndexPresenter do
  describe "#institutions" do
    it "presents the relevant states in order" do
      first_institution = create(:institution, name: "One, Two, Three")
      second_institution = create(:institution, name: "School of Rock")
      third_institution = create(:institution, name: "One Cool School")
      presenter = InstitutionsIndexPresenter.new(query: "School")

      institutions = presenter.institutions
      institutions.first.country.name

      expect(institutions.length).to eq 2
      expect(institutions.map(&:name)).to eq [
        "One Cool School",
        "School of Rock",
      ]
    end
  end
end
