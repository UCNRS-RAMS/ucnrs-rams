class HomeIndexFlow
  def initialize(page)
    @page = page
  end

  def visit_home_index_page
    page.visit("/")
  end

  def dismiss_modal
    page.find(".modal button.active", text: "Let's go!").click
  end

  def on_home_index_page?
    page.has_css?("body.home.home-index")
  end

  def filter_by_status(status)
    page.select(status, from: "status")
  end

  def has_visits_count?(count)
    page.all("tr.visit", count: count)
  end

  def has_active_my_visits_tab?
    page.has_css?("a.nav-link.active", text: "Visits")
  end

  def has_displayed_visits?(number)
    page.has_selector?("tr.visit", count: number)
  end

  def has_pagination_link?(text)
    page.has_css?("span.#{text}")
  end

  def has_selected_page_number_link?(number)
    page.has_css?("span.current", text: number)
  end

  def has_page_number_link?(number)
    page.has_css?("span.page a", text: number)
  end

  def go_to_page(page_number)
    page.find("a", text: page_number).click
  end

  def has_no_pagination_links?
    page.has_no_selector?("nav.pagination")
  end

  private

  attr_reader :page
end
