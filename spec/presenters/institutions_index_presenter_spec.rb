require "rails_helper"

RSpec.describe InstitutionsIndexPresenter do
  describe "#institutions" do
    it "presents the relevant states in order" do
      first_institution = create(:institution, name: "One, Two, Three")
      second_institution = create(:institution, name: "School of Rock")
      third_institution = create(:institution, name: "One Cool School")
      presenter = InstitutionsIndexPresenter.new(query: "School")

      institutions = presenter.institutions

      expect(institutions.length).to eq 2
      expect(institutions[0].name).to eq "One Cool School"
      expect(institutions[1].name).to eq "School of Rock"
      expect(institutions.any? { |institution| institution.id == first_institution.id }).to be_falsey
    end
  end
end

