class DateSelectionFlow
  def initialize(page)
    @page = page
  end

  def visit_new_visit_page
    page.visit("/visits/new")
  end

  def click_calendar_icon_for(input)
    page.find("img.#{input}").click
  end

  def has_open_calendar_modal?
    page.has_selector?("#modal")
  end

  def has_no_open_calendar_modal?
    page.has_no_selector?("#modal")
  end

  def has_displayed_calendar_for?(month_and_year)
    page.has_css?("div#calendar span.calendar-title", text: month_and_year)
  end

  def select_date(mm:, dd:, yyyy:)
    page.find_by_id("#{yyyy}-#{mm}-#{dd}").click
  end

  def has_date_input_value?(field:, value:)
    page.has_field?(field, with: value)
  end

  def close_modal
    resize_window
    page.find("button", text: "Okay").click
  end

  def go_to_next_month
    page.click_link("Next")
  end

  private

  attr_reader :page

  def resize_window
    Capybara.current_session.current_window.resize_to(1000, 1000)
  end
end
