class ProjectShowFlow
  def initialize(page:, project_id:, reserve_id:)
    @page = page
    @project_id = project_id
    @reserve_id = reserve_id
  end

  def visit_show_page
    page.visit("/manager/reserves/#{reserve_id}/projects/#{project_id}")
  end

  def click_on_summary
    page.click_link("summary")
  end

  def click_on_details
    page.click_link("details")
  end

  private

  attr_reader :page, :reserve_id, :project_id
end
