require "rails_helper"

RSpec.describe InstitutionsIndexPresenter do
  describe "#results" do
    it "presents matching institutions in order" do
      first_institution = create(:institution, name: "One, Two, Three")
      second_institution = create(:institution, name: "School of Rock")
      third_institution = create(:institution, name: "One Cool School")
      presenter = InstitutionsIndexPresenter.new(query: "School")

      results = presenter.results

      expect(results.length).to eq 2
      expect(results.map { |result| result[:name] }).to eq [
        "One Cool School",
        "School of Rock",
      ]
    end
  end
end
