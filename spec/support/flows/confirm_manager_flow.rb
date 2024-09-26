class ConfirmManagerFlow
  def initialize(page)
    @page = page
  end

  def visit_manager_reserve_dashboard(reserve_id)
    page.visit("/manager/reserves/#{reserve_id}/dashboard")
  end

  def on_manager_reserve_dashboard?
    page.has_css?("body.manager.dashboard")
  end

  def on_root_home_page?
    page.has_css?("body.dashboard")
  end

  private

  attr_reader :page
end
