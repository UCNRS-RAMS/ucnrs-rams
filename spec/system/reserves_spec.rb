require "rails_helper"

RSpec.describe "Reserves", type: :system, js: true do
  describe "when on index page", js: true do
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

    it "shows the reserve tags and allows the user to click and filter reserves", js: true do
      reserve1 = create(:reserve)
      reserve2 = create(:reserve)
      reserve3 = create(:reserve)
      create(:reserve_tag, reserve: reserve1, category: :geographic, name: "River")
      create(:reserve_tag, reserve: reserve1, category: :ecosystem, name: "Marsh")
      create(:reserve_tag, reserve: reserve2, category: :geographic, name: "River")
      create(:reserve_tag, reserve: reserve2, category: :ecosystem, name: "Marsh")
      create(:reserve_tag, reserve: reserve2, category: :geographic, name: "Beach")
      create(:reserve_tag, reserve: reserve3, category: :geographic, name: "Beach")
      create(:reserve_tag, reserve: reserve3, category: :ecosystem, name: "Marsh")

      flow = ReservesFlow.new(page)

      flow.visit_reserves_page

      expect(flow).to have_reserves_count(3)
      expect(flow).to be_on_reserves_page
      expect(flow).to be_displaying_tag("Geographic")
      expect(flow).to be_displaying_tag("Ecosystem")
      expect(page).to be_axe_clean
    end

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
      expect(page).to be_axe_clean

      flow.click_reserve_tag("Geographic")

      expect(flow).to be_displaying_tag("River")
      expect(flow).to be_displaying_tag("Marsh")
      expect(flow).to be_displaying_tag("Beach")

      flow.click_reserve_tag("River")
      flow.click_reserve_tag("Beach")
      sleep(0.1)

      expect(flow).to have_reserves_count(3)
    end

    it "reset filters and shows all the reserves when click on 'Clear Selection & Start Over'", js: true do
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
      expect(page).to be_axe_clean

      flow.click_reserve_tag("Geographic")

      sleep(0.1)

      expect(flow).to be_displaying_tag("River")
      expect(flow).to be_displaying_tag("Marsh")
      expect(flow).to be_displaying_tag("Beach")

      expect(flow).to have_reserves_count(3)

      flow.click_reserve_tag("River")
      sleep(0.1)

      expect(flow).to have_reserves_count(2)

      flow.click_clear_btn("Clear Selection & Start Over")

      expect(flow).not_to be_displaying_tag("River")
      expect(flow).not_to be_displaying_tag("Beach")
      expect(flow).to have_reserves_count(3)
    end
  end

  describe "when on show page" do
    it "allows the user view the amenities, calendar, rules_and_directions and waivers page", js: true do
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

      flow.go_to_waivers
      expect(flow).to be_displaying_waivers_section
      expect(page).to be_axe_clean

      flow.go_to_rules_and_directions
      expect(flow).to be_displaying_rules_and_directions_section
      expect(page).to be_axe_clean

      flow.go_to_more_information
      expect(flow).to be_displaying_more_information_section
      expect(page).to be_axe_clean

      flow.go_to_amenities
      expect(flow).to be_displaying_amenities_section
    end
  end

  describe "reserve calendar" do
    it "display user_visit for a visit", js: true do
      user = create(:user, :confirmed)
      sign_in(user)
      reserve = create(:reserve)
      visit = create(:visit, reserve: reserve)
      create(:user_visit, visit: visit )

      flow = ReservesFlow.new(page)

      flow.visit_reserves_show_page(reserve.id)
      flow.go_to_calendar

      expect(flow).to have_visit_visitor("1")
      expect(flow).to have_visitor_bar(visit.starts_at.strftime("%Y-%m-%d"))
    end

    it "display amenity_visit for a visit", js: true do
      user = create(:user, :confirmed)
      sign_in(user)
      reserve = create(:reserve)
      visit = create(:visit, reserve: reserve)
      create(:user_visit, visit: visit)
      create(:amenity_visit, visit: visit)
      flow = ReservesFlow.new(page)

      flow.visit_reserves_show_page(reserve.id)
      flow.go_to_calendar

      expect(flow).to have_amenity_visitor
      expect(flow).to have_one_amenity_visitor
    end
  end

  describe "reserve calendar modal" do
    it "display modal after click on user_visit and amenity_visit bar", js: true do
      reserve = create(:reserve)
      user = create(:user, :confirmed)
      sign_in(user)
      visit = create(:visit, reserve: reserve)
      create(:user_visit, visit: visit, arrives_at: visit.starts_at, departs_at: visit.ends_at)
      create(:amenity_visit, visit: visit)
      flow = ReservesFlow.new(page)

      flow.visit_reserves_show_page(reserve.id)
      flow.go_to_calendar

      page.first(".visitor-count").click
      expect(flow).to have_modal

      page.click_on("Close")
      expect(flow).not_to have_modal

      page.first(".amenity-count").click
      expect(flow).to have_modal

      page.click_on("Close")
      expect(flow).not_to have_modal
    end
  end

  describe "reserve calendar with user is not login" do
    it "display approved visits for reserve", js: true do
      reserve = create(:reserve)
      visit = create(:visit, reserve: reserve, status: "approved", starts_at: Time.current, ends_at: Time.current+1)

      flow = ReservesFlow.new(page)

      flow.visit_reserves_show_page(reserve.id)
      flow.go_to_calendar

      expect(flow).to have_approved_visit_bar
    end

    it "do not display visits which are not approved", js: true do
      reserve = create(:reserve)
      visit = create(:visit, reserve: reserve, status: "incomplete")

      flow = ReservesFlow.new(page)

      flow.visit_reserves_show_page(reserve.id)
      flow.go_to_calendar

      expect(flow).not_to have_approved_visit_bar
    end
  end
end
