require "rails_helper"

RSpec.describe Reserves::Calendar::AmenityPresenter do
  describe "#visit_link_params" do
    it "returns params for visits_link method" do
      reserve = create(:reserve)
      amenity = AmenityPresenter.new(create(:amenity, reserve_id: reserve.id))
      visit = create(:visit, reserve_id: reserve.id)
      show_presenter = Reserves::Calendar::AmenityPresenter.new(amenity: amenity, visit: visit)

      output = Manager::Dashboard::BarPresenter.new(
        link_classes: "",
        background_classes: "amenity-count left-radius right-radius",
        text_classes: "display-none",
        text: "Amenity 1 (0 visitors)",
        path: "/reserves/#{reserve.id}/calendar/visits/#{visit.id}",
      )

      expect(show_presenter.visit_link_params).to eq output
    end
  end
end
