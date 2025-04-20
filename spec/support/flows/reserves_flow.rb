class ReservesFlow
  def initialize(page)
    @page = page
  end

  def visit_reserves_page
    page.visit("/reserves")
  end

  def within(selector, &block)
    begin
      @page_scope = selector
      block.call
    ensure
      @page_scope = nil
    end
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

  def displaying_tag?(tag)
    page.has_css?(".tag-btn>label", text: tag)
  end

  def click_reserve_tag(tag)
    page.find(".tag-btn>label",text: tag).click
  end

  def click_clear_btn(tag)
    page.find(".submit-btn",text: tag).click
  end

  def has_reserves_count?(expected_reserves)
    page.all('.reserve-cards .card').count.eql?(expected_reserves)
  end

  def go_to_calendar
    page.click_link("Calendar")
  end

  def displaying_calendar_section?
    page.has_css?("turbo-frame#calendar")
  end

  def go_to_waivers
    page.click_link("Waivers")
  end

  def displaying_waivers_section?
    page.has_css?("section.waivers.waivers-index")
  end

  def go_to_rules_and_directions
    page.click_link("Rules & Directions")
  end

  def displaying_rules_and_directions_section?
    page.has_css?("section.rules_and_directions.rules_and_directions-show")
  end

  def go_to_more_information
    page.click_link("More Information")
  end

  def displaying_more_information_section?
    page.has_css?("section.addendums.addendums-index")
  end

  def has_visit_visitor?(count)
    page.has_css?(".visitor-count", text: "#{count} Visitors")
  end

  def has_visitor_bar?(date_id, count = 1)
    within "#{date_id}" do
      page.has_css?(".visitor-count", text: "#{count} Visitor")
    end
  end

  def has_approved_visit_bar?
    page.has_css?(".left-radius-approved")
  end

  def has_reserve_filter_dropdown?
    page.has_css?("#reserve_filter")
  end

  def has_amenity_visitor?
    page.has_css?(".amenity-count")
  end

  def has_one_amenity_visitor?
    page.has_text?("1 visitor")
  end

  def has_modal?
    page.has_css?(".calendar-modal")
  end

  private

  attr_reader :page
end
