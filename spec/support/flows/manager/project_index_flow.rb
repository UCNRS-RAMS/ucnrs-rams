class Manager::ProjectIndexFlow
  def initialize(page)
    @page = page
  end

  def visit_manager_projects_index_page(reserve)
    page.visit("/manager/reserves/#{reserve.id}/projects")
  end

  def on_manager_projects_index_page?
    page.has_css?("body.manager.projects.projects-index")
  end

  def has_active_projects_tab?
    page.has_css?("a.nav-link.active", text: "Projects")
  end

  def has_projects_count?(count)
    page.all("tr.project", count: count)
  end

  def has_projects_in_order?(projects)
    sleep(0.5)
    project_ids = projects.map { |project| "project_#{project.id}" }
    row_ids = page.find_all("tr.project").map { |row| row[:id] }
    row_ids == project_ids
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

  def has_displayed_projects?(number)
    page.has_selector?("tr.project", count: number)
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
    resize_window
    page.find("a", text: page_number).click
  end
  
  def go_to_last_page
    resize_window
    page.find("span.last a").click
  end

  def go_to_last_page
    resize_window
    page.find("span.last a").click
  end

  def has_no_pagination_links?
    page.has_no_selector?("nav.pagination")
  end

  private

  attr_reader :page

  def resize_window
    Capybara.current_session.current_window.resize_to(1000, 1000)
  end
end
