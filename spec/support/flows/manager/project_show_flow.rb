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

  def showing_summary_box?
    page.has_css?(".project-summary-box")
  end

  def showing_menu_bar?
    page.has_css?(".project-menu-bar")
  end

  def has_section?(section)
    page.has_css?("section.#{section}")
  end

  def has_navigation_link?(text)
    page.has_css?("a", text: text)
  end

  def showing_summary_table?
    page.has_css?("table#team-summary-table")
  end

  def has_no_inactive_user?
    page.has_no_css?(".inactive-user")
  end

  def has_inactive_user?
    page.has_css?(".inactive-user")
  end

  def showing_funding_summary_table?
    page.has_css?("table#funding-summary-table")
  end

  def showing_permit_summary_list?
    page.has_css?("div#permit-summary-list")
  end

  def showing_text?(text)
    page.has_css?("p", text: text)
  end

  def showing_form?(form)
    page.has_css?(form)
  end

  def not_showing_form?(form)
    page.has_no_css?(form)
  end

  def has_heading?(heading)
    page.has_css?("h3", text: heading)
  end

  private

  attr_reader :page, :reserve_id, :project_id
end
