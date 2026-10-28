require "rails_helper"

RSpec.describe "Reserves", type: :request do
  describe "GET /reserves" do
    it "lists every reserve alphabetically, each linking to its own page" do
      sierra = create(:reserve, name: "Sierra Nevada")
      coast = create(:reserve, name: "Coastal Range")

      get "/reserves"

      page = Capybara.string(response.body)
      expect(response).to be_ok
      expect(page).to have_css("body.reserves.reserves-index")
      expect(page.all(".reserve-cards .card h2").map(&:text)).to eq [ "Coastal Range", "Sierra Nevada" ]
      expect(page).to have_link("Sierra Nevada", href: "/reserves/#{sierra.id}")
      expect(page).to have_link("Coastal Range", href: "/reserves/#{coast.id}")
    end

    it "renders the tag categories and tag names as filter checkboxes" do
      reserve = create(:reserve)
      create(:reserve_tag, reserve: reserve, category: :geographic, name: "River")
      create(:reserve_tag, reserve: reserve, category: :ecosystem, name: "Marsh")

      get "/reserves"

      page = Capybara.string(response.body)
      expect(page).to have_css("label[for='tags_selected_geographic']", text: "Geographic")
      expect(page).to have_css("label[for='tags_selected_ecosystem']", text: "Ecosystem")
      expect(page).to have_css(
        "input#tags_selected_River[name='tag_names[geographic][]'][value='River']", visible: :all
      )
      expect(page).to have_css(
        "input#tags_selected_Marsh[name='tag_names[ecosystem][]'][value='Marsh']", visible: :all
      )
    end

    it "filters the reserve cards by the selected tag names" do
      river = create(:reserve, name: "River Reserve")
      beach = create(:reserve, name: "Beach Reserve")
      create(:reserve_tag, reserve: river, category: :geographic, name: "River")
      create(:reserve_tag, reserve: beach, category: :geographic, name: "Beach")

      get "/reserves", params: { tag_names: { "Geographic" => [ "Beach" ] } }

      page = Capybara.string(response.body)
      expect(page).to have_css(".reserve-cards .card h2", count: 1)
      expect(page).to have_css(".reserve-cards .card h2", text: "Beach Reserve")
      expect(page).to have_no_css(".reserve-cards .card h2", text: "River Reserve")
    end

    it "matches reserves carrying any of the selected tag names" do
      river = create(:reserve, name: "River Reserve")
      beach = create(:reserve, name: "Beach Reserve")
      marsh = create(:reserve, name: "Marsh Reserve")
      create(:reserve_tag, reserve: river, category: :geographic, name: "River")
      create(:reserve_tag, reserve: beach, category: :geographic, name: "Beach")
      create(:reserve_tag, reserve: marsh, category: :ecosystem, name: "Marsh")

      get "/reserves", params: { tag_names: { "Geographic" => [ "River", "Beach" ] } }

      page = Capybara.string(response.body)
      expect(page).to have_css(".reserve-cards .card h2", count: 2)
      expect(page).to have_no_css(".reserve-cards .card h2", text: "Marsh Reserve")
    end

    it "filters the reserve cards by the search term" do
      create(:reserve, name: "Sierra Nevada")
      create(:reserve, name: "Coastal Range")

      get "/reserves", params: { search_filter: "Sierra" }

      page = Capybara.string(response.body)
      expect(page).to have_css(".reserve-cards .card h2", count: 1)
      expect(page).to have_css(".reserve-cards .card h2", text: "Sierra Nevada")
    end
  end

  describe "GET /reserves/:id" do
    it "renders the reserve and swaps the amenities tab into the details frame by default" do
      reserve = create(:reserve, name: "RAMS Test Reserve")

      get "/reserves/#{reserve.id}"

      page = Capybara.string(response.body)
      expect(response).to be_ok
      expect(page).to have_css("h1", text: "RAMS Test Reserve")
      expect(page).to have_css("turbo-frame#details[src='/reserves/#{reserve.id}/amenities']")
      expect(page).to have_link("Amenities & Rates", href: "/reserves/#{reserve.id}/amenities")
      expect(page).to have_link("Waivers", href: "/reserves/#{reserve.id}/waivers")
      expect(page).to have_link(
        "Rules & Directions", href: "/reserves/#{reserve.id}/rules_and_directions"
      )
      expect(page).to have_link("More Information", href: "/reserves/#{reserve.id}/more_information")
      expect(page).to have_link(
        "Calendar",
        href: "/reserves/#{reserve.id}/calendar?partial_name=calendar&start_date=#{Time.zone.today}",
      )
    end

    it "renders the amenities tab" do
      reserve = create(:reserve)
      create(:amenity, reserve: reserve, title: "Bunkhouse", comment: "Two rooms")

      get "/reserves/#{reserve.id}/amenities"

      page = Capybara.string(response.body)
      expect(page).to have_css("section.amenities.amenities-index")
      expect(page).to have_css("section.amenities h2", text: "Bunkhouse")
      expect(page).to have_css("section.amenities .description", text: "Two rooms")
    end

    it "renders the calendar tab inside its own turbo frame" do
      reserve = create(:reserve, public_calendar_access: true)

      get "/reserves/#{reserve.id}/calendar",
        params: { partial_name: "calendar", start_date: Time.zone.today.iso8601 }

      page = Capybara.string(response.body)
      expect(page).to have_css("turbo-frame#calendar .simple-calendar")
    end

    it "renders the waivers tab" do
      reserve = create(:reserve)
      create(:reserve_waiver, reserve: reserve, waiver: create(:waiver, name: "Liability Waiver"))

      get "/reserves/#{reserve.id}/waivers"

      page = Capybara.string(response.body)
      expect(page).to have_css("section.waivers.waivers-index")
      expect(page).to have_content("Liability Waiver")
    end

    it "renders the rules and directions tab" do
      reserve = create(:reserve, :with_rules_and_directions)

      get "/reserves/#{reserve.id}/rules_and_directions"

      page = Capybara.string(response.body)
      expect(page).to have_css("section.rules_and_directions.rules_and_directions-show")
      expect(page).to have_content(reserve.rules_and_regulations.to_plain_text)
      expect(page).to have_content(reserve.directions.to_plain_text)
    end

    it "renders the more information tab" do
      reserve = create(:reserve)
      create(:reserve_addendum, reserve: reserve, name: "Fire Season Rules")

      get "/reserves/#{reserve.id}/more_information"

      page = Capybara.string(response.body)
      expect(page).to have_css("section.addendums.addendums-index")
      expect(page).to have_css("section.addendums h2", text: "Fire Season Rules")
    end
  end
end
