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

  def click_on_fundings
    page.click_link("funding")
  end

  def click_on_team
    page.click_link("team_memberships")
  end

  def click_on_visits
    page.click_link("visits")
  end

  def click_on_permits
    page.click_link("permits")
  end

  def click_on_activity_and_notes
    page.click_link("Activity & Notes")
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

  def not_showing_section?(section)
    page.has_no_css?("section.#{section}")
  end

  def has_navigation_link?(text)
    page.has_css?("a", text: text)
  end

  def has_team_membership_edit_link?(team_membership)
    page.has_css?("a[href='/manager/reserves/#{team_membership.project.reserve_id}/team_memberships/#{team_membership.id}/edit']")
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

  def not_showing_questions?
    page.has_no_css?("#permit-questions")
  end

  def showing_questions?
    page.has_css?("#permit-questions")
  end

  def has_heading?(heading)
    page.has_css?("h3", text: heading)
  end

  def not_showing_fundings?
    page.has_no_css?("#project-fundings")
  end

  def showing_fundings?
    page.has_css?("#project-fundings")
  end

  def click_on_funding_edit
    page.find("a", text: "Edit").click
  end

  def showing_funding_edit_modal?
    page.has_css?("section.text")
  end

  def has_text_field?(value)
    page.has_field?(value, type: "text")
  end

  def has_hidden_field?(value)
    page.has_field?(value, type: "hidden")
  end

  def has_select_field?(value)
    page.has_field?(value, type: "select")
  end

  def has_n_table_rows?(css_class:, count:)
    page.all("#{css_class} tr").count.eql? count
  end

  def in_visits_section(&block)
    page.within(".project-visits", &block)
  end

  def has_table_data_text?(child:, text:)
    page.has_css?("td:nth-child(#{child})", text: text)
  end

  def not_showing_activity_and_notes?
    page.has_no_css?("section.activity-and-notes")
  end

  def showing_activity_and_notes?
    page.has_css?("section.activity-and-notes")
  end

  private

  attr_reader :page, :reserve_id, :project_id
end
