class DashboardFlow
  def initialize(page)
    @page = page
  end

  def visit_dashboard
    @page.visit("/dashboard")
  end
end
