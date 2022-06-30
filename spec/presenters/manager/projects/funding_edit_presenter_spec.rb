require "rails_helper"

RSpec.describe Manager::Projects::FundingEditPresenter do
  let(:reserve) { create(:reserve) }
  let(:project) { create(:project, reserve: reserve) }
  let(:funding) { create(:funding, project: project) }
  let(:form) { ProjectFundingForm.new(params: { id: funding.id }) }
  let(:presenter) { Manager::Projects::FundingEditPresenter.new(form: form, reserve: reserve) }

  describe "#editing_funding" do
    it "should return the funding presenter object for manager" do
      expect(presenter.editing_funding.id).to eq(funding.id)
      expect(presenter.editing_funding.class).to eq(Manager::Projects::FundingPresenter)
    end
  end

  describe "#funding_form_path" do
    it "should returns the form action url in manager namespace" do
      url = presenter.funding_form_path

      expect(url).to eq("/manager/reserves/#{reserve.id}/projects/#{project.id}/fundings/#{funding.id}")
    end
  end
end
