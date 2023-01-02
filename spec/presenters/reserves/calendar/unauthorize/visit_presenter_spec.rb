require "rails_helper"

RSpec.describe Reserves::Calendar::Unauthorize::VisitPresenter do
  describe "#visit_link_params" do
    it "returns params for visits_link method" do
      reserve = create(:reserve, name: "Reserve 1")
      visit = create(:visit, reserve_id: reserve.id, status: "incomplete")
      visit_presenter = Reserves::Calendar::Unauthorize::VisitPresenter.new(visit: visit)

      output = Reserves::Calendar::Unauthorize::BarPresenter.new(
        link_classes: "",
        background_classes: "",
        inner_classes: "",
        text_classes: "",
        text: "Reserve 1",
        status_class: "incomplete",
        path: "/reserves/#{reserve.id}/calendar/visits/#{visit.id}",
      )

      expect(visit_presenter.visit_link_params).to eq output
    end
  end
end
