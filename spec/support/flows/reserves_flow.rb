class ReservesFlow
  def initialize(page)
    @page = page
  end

  def visit_reserves_page
    page.visit("/reserves")
  end

  def on_reserves_page?
    page.has_css?("body.reserves.reserves-index")
  end

  def click_reserve_image
    page.find("img.reserve-image").click
  end

  def visit_reserves_show_page(reserve_id)
    page.visit("/reserves/#{reserve_id}")
  end

  def go_to_amenities
    page.click_link("Amenities & Rates")
  end

  def displaying_amenities_section?
    page.has_css?("section.amenities.amenities-index")
  end

  def go_to_calendar
    page.click_link("Calendar")
  end

  def displaying_calendar_section?
    page.has_css?("section.calendars.calendars-show")
  end

  def go_to_waivers
    page.click_link("Waivers")
  end

  def displaying_waivers_section?
    page.has_css?("section.waivers.waivers-index")
  end

  def go_to_rules_and_regulations
    page.click_link("Rules & Regulations")
  end

  def displaying_rules_and_regulations_section?
    page.has_css?("section.rules_and_regulations.rules_and_regulations-show")
  end

  private

  attr_reader :page
end
