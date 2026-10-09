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

  def within(selector, &block)
    begin
      @page_scope = selector
      block.call
    ensure
      @page_scope = nil
    end
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

  private

  attr_reader :page

  def resize_window
    Capybara.current_session.current_window.resize_to(1000, 1000)
  end
end
