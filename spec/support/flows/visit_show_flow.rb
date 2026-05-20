class VisitShowFlow
  def initialize(page)
    @page = page
  end

  def visit_show_page(visit_id)
    @page.visit("/visits/#{visit_id}")
  end

  def showing_visit_summary?
    @page.has_css?(".visit")
  end
end
