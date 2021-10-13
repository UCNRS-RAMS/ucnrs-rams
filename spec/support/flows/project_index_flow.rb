class ProjectIndexFlow
  def initialize(page)
    @page = page
  end

  def visit_projects_index_page
    page.visit("/projects")
  end

  def on_projects_index_page?
    page.has_css?("body.projects.projects-index")
  end

  def filter_by_status(status)
    page.select(status, from: "status")
  end

  def has_projects_count?(count)
    page.all("tr.project", count: count)
  end

  def has_projects_in_order?(projects)
    project_ids = projects.map { |project| "project_#{project.id}" }
    row_ids = page.find_all("tr.project").map { |row| row[:id] }

    row_ids == project_ids
  end

  def has_active_my_projects_tab?
    page.has_css?("a.nav-link.active", text: "My Projects")
  end

  def has_project_with?(
    id:,
    title:,
    timeframe:,
    project_type:,
    number_of_visits:,
    most_recent_visit:,
    reserve_name:
  )
    page.within "tr#project_#{id}" do
      page.has_content?(title) &&
        page.has_content?(timeframe) &&
        page.has_content?(project_type) &&
        page.has_content?(number_of_visits) &&
        page.has_content?(most_recent_visit) &&
        page.has_content?(reserve_name)
    end
  end

  private

  attr_reader :page
end
