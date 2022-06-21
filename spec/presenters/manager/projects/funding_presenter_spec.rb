require "rails_helper"

RSpec.describe Manager::Projects::FundingPresenter do
  describe "#fundings" do
    it "returns the edit path for funding form" do
      reserve = create(:reserve)
      project = create(:project, reserve: reserve)
      funding = create(:funding, project: project)
      presenter = Manager::Projects::FundingPresenter.new(funding)

      expect(presenter.edit_funding_form_path).to eq("/manager/reserves/#{reserve.id}/projects/#{project.id}/fundings/#{funding.id}/edit")
    end
  end
end
