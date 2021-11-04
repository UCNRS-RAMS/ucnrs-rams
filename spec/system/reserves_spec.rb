require "rails_helper"

RSpec.describe "Reserves", type: :system, js: true do
  describe "when on index page" do
    it "shows the reserves and allows the user to click and view reserve show page", js: true do
      reserve = create(:reserve, name: "RAMS Test Reserve")
      amenity = create(:amenity, reserve: reserve, title: "Amenity one", comment: "comment")
      rate_category = create(:amenity_rate_category, reserve: reserve)
      rate = create(:amenity_rate, amenity: amenity, amenity_rate_category: rate_category)
      AmenityPresenter.new(amenity)

      flow = ReservesFlow.new(page)

      flow.visit_reserves_page
      expect(flow).to be_on_reserves_page
      expect(page).to be_axe_clean

      flow.click_reserve_image
      expect(flow).to be_displaying_amenities_section
    end
  end

  describe "when on show page" do
    it "allows the user view the amenities, calendar, rules_and_regulations and waivers page", js: true do
      reserve = create(:reserve, name: "RAMS Test Reserve")
      amenity = create(:amenity, reserve: reserve, title: "Amenity one", comment: "comment")
      rate_category = create(:amenity_rate_category, reserve: reserve)
      rate = create(:amenity_rate, amenity: amenity, amenity_rate_category: rate_category)
      AmenityPresenter.new(amenity)

      flow = ReservesFlow.new(page)

      flow.visit_reserves_show_page(reserve.id)
      expect(flow).to be_displaying_amenities_section
      expect(page).to be_axe_clean

      flow.go_to_calendar
      expect(flow).to be_displaying_calendar_section
      expect(page).to be_axe_clean

      flow.go_to_waivers
      expect(flow).to be_displaying_waivers_section
      expect(page).to be_axe_clean

      flow.go_to_rules_and_regulations
      expect(flow).to be_displaying_rules_and_regulations_section
      expect(page).to be_axe_clean

      flow.go_to_more_information
      expect(flow).to be_displaying_more_information_section
      expect(page).to be_axe_clean

      flow.go_to_amenities
      expect(flow).to be_displaying_amenities_section
    end
  end
end
