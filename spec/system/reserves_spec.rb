require "rails_helper"

RSpec.describe "Reserves", type: :system, js: true do
  describe "when on index page" do
    it "shows the reserve name tags and allows the user to click and filter reserves", js: true do
      reserve1 = create(:reserve)
      reserve2 = create(:reserve)
      reserve3 = create(:reserve)
      create(:reserve_tag, reserve: reserve1, category: :geographic, name: "River")
      create(:reserve_tag, reserve: reserve1, category: :ecosystem, name: "Marsh")
      create(:reserve_tag, reserve: reserve2, category: :geographic, name: "River")
      create(:reserve_tag, reserve: reserve2, category: :ecosystem, name: "Marsh")
      create(:reserve_tag, reserve: reserve2, category: :geographic, name: "Beach")
      create(:reserve_tag, reserve: reserve3, category: :ecosystem, name: "Marsh")
      create(:reserve_tag, reserve: reserve3, category: :geographic, name: "Beach")

      flow = ReservesFlow.new(page)

      flow.visit_reserves_page

      expect(flow).to be_on_reserves_page
      expect(flow).to have_reserves_count(3)
      expect(flow).to be_displaying_tag("Ecosystem")
      expect(flow).to be_displaying_tag("Geographic")

      flow.click_reserve_tag("Geographic")

      expect(flow).to be_displaying_tag("River")
      expect(flow).to be_displaying_tag("Marsh")
      expect(flow).to be_displaying_tag("Beach")

      flow.click_reserve_tag("Beach")

      expect(page).to have_css(".reserve-cards .card", count: 2)

      flow.click_reserve_tag("River")

      expect(page).to have_css(".reserve-cards .card", count: 3)
    end
  end

  describe "reserve calendar modal" do
    it "display modal after click on user_visit and amenity_visit bar", js: true do
      reserve = create(:reserve)
      user = create(:user, :confirmed)
      sign_in(user)
      visit = create(:visit, reserve: reserve, status: :approved)
      create(:user_visit, visit: visit, arrives_at: visit.starts_at, departs_at: visit.ends_at)
      create(:amenity_visit, visit: visit)
      flow = ReservesFlow.new(page)

      flow.visit_reserves_show_page(reserve.id)
      flow.go_to_calendar

      page.first(".visitor-count").click
      expect(flow).to have_modal

      page.find(".close").click
      expect(flow).to have_no_modal

      page.first(".amenity-count").click
      expect(flow).to have_modal

      page.find(".close").click
      expect(flow).to have_no_modal
    end
  end
end
