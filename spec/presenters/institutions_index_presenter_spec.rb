require "rails_helper"

RSpec.describe InstitutionsIndexPresenter do
  describe "#results" do
    it "searches once when results are requested repeatedly" do
      results = [ { name: "Example" } ]
      expect(AggregatedSearch).to receive(:institution_search).once.and_return(results)
      presenter = described_class.new(query: "Example")

      expect(presenter.results).to eq(results)
      expect(presenter.results).to eq(results)
    end

    it "presents matching institutions in order" do
      first_institution = create(:institution, name: "One, Two, Three")
      second_institution = create(:institution, name: "School of Rock")
      third_institution = create(:institution, name: "One Cool School")
      presenter = InstitutionsIndexPresenter.new(query: "School")

      results = presenter.results

      expect(results.length).to eq 2
      # because exact starts with matches should come before partial matches
      expect(results.map { |result| result[:name] }).to eq [
        "School of Rock",
        "One Cool School",
      ]
    end
  end
end
