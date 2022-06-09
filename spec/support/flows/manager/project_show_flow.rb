class ProjectShowFlow
  def initialize(page:, project_id:, reserve_id:)
    @page = page
    @project_id = project_id
    @reserve_id = reserve_id
  end

  def visit_show_page
    page.visit("/manager/reserves/#{reserve_id}/projects/#{project_id}")
  end

  private

  attr_reader :page, :reserve_id, :project_id
end
