class Manager::DashboardFlow
  def initialize(page, reserve, user)
    @page = page
    @reserve = reserve
    @user = user
    @user.managed_reserve_ids = @reserve.id
  end

  def visit_manager_dashboard
    page.visit("/manager/reserves/#{@reserve.id}/dashboard")
  end

  def manager_dashboard?
    page.has_css?(".manager")
  end

  def dashboard_partial?
    page.has_css?(".content")
  end

  def list_partial?
    page.has_css?(".visits-search-list")
  end

  def calendar_partial?
    page.has_css?(".calendar-container")
  end

  def has_visit_visitor?
    page.has_css?(".visitor-count")
  end

  def has_amenity_visitor?
    page.has_css?(".amenity-count")
  end

  def has_one_visitor?
    page.has_text?("1 Visitor")
  end

  def has_one_amenity_visitor?
    page.has_text?("1 visitor")
  end

  def has_modal?
    page.has_css?(".calendar-modal")
  end

  private

  attr_reader :page

  def resize_window
    Capybara.current_session.current_window.resize_to(1000, 1000)
  end
end
