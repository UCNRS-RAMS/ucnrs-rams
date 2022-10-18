require "rails_helper"

RSpec.describe Manager::Visits::QuestionsIndexPresenter do
  describe "#save_btn_partial_path" do
    it "return save btn partial path" do
      visit = create(:visit)
      presenter = Manager::Visits::QuestionsIndexPresenter.new(visit: visit)

      expect(presenter.save_btn_partial_path).to eq("manager/visits/reserve_info/save_btn")
    end
  end

  describe "#form_url" do
    it "returns visit form url in manager namespace" do
      reserve = create(:reserve)
      visit = create(:visit, reserve_id: reserve.id)
      presenter = Manager::Visits::QuestionsIndexPresenter.new(visit: visit)

      expect(presenter.form_url).to eq("/manager/reserves/#{reserve.id}/visits/#{visit.id}/reserve_info")
    end
  end
end
