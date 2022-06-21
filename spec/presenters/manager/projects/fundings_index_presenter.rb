require "rails_helper"

RSpec.describe Manager::Projects::FundingsIndexPresenter do
  describe "#fundings" do
    it "should returns an array of Manager::Projects::Funding for each funding" do
      reserve = create(:reserve)
      project = create(:project, reserve: reserve)
      fundings = create_list(:funding, 3, project: project)

      presenter = Manager::Projects::FundingsIndexPresenter.new(project: project)
      results = presenter.fundings

      expect(results.map(&:id)).to eq [
        fundings[0].id,
        fundings[1].id,
        fundings[2].id,
      ]
      expect(results.map(&:class).uniq).to eq([Manager::Projects::FundingPresenter])
    end
  end
end
