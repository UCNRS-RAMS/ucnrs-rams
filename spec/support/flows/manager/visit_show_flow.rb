class VisitShowFlow
  def initialize(page:, visit_id:, reserve_id:)
    @page = page
    @visit_id = visit_id
    @reserve_id = reserve_id
  end

  def visit_show_page
    page.visit("/manager/reserves/#{reserve_id}/visits/#{visit_id}")
  end

  def showing_summary_box?
    page.has_css?(".visit-summary-box")
  end

  def showing_menu_bar?
    page.has_css?(".visit-menu-bar")
  end

  def showing_trash_and_status_btn?
    page.has_css?("#status_and_trash_btn")
  end

  def click_on_status_btn
    page.find(".btn-status").click
  end

  def click_on_details_link
    page.find("#details").click
  end

  def change_purpose_of_visit
    page.find("#visit_purpose_of_visit").set("changed")
  end

  def change_visit_start_date
    page.fill_in("visit_start_date", with: Time.zone.today)
  end

  def change_visit_end_date
    page.fill_in("visit_end_date", with: Time.zone.today + 2)
  end

  def change_visit_start_time
    page.find("#visit_start_time").select("1:00 AM")
  end

  def change_visit_end_time
    page.find("#visit_end_time").select("2:00 AM")
  end

  def showing_flash_message?
    page.has_css?(".notice")
  end

  def click_on_save_btn
    page.click_on("Save Changes")
  end

  def record_updated?
    page.find("#visit_purpose_of_visit").value == "changed"
  end

  def showing_summary_partial?
    page.has_css?(".summary")
  end

  def click_on_trash_icon
    page.accept_confirm do
      page.find("#trash-icon").click
    end
  end

  def click_on_details_btn
    page.find("#details").click
  end

  def click_on_reserve_info_btn
    page.find("#reserve_info").click
  end

  def click_on_submit_btn
    page.find("button.active").click
  end

  def showing_purpose_of_visit?
    page.has_css?("#project-type-research")
  end

  def showing_reserve_specific_questions?
    page.has_css?(".questions")
  end

  def success_message?
    page.has_css?(".notice")
  end

  def error_message?
    page.has_css?(".alert")
  end

  def no_question_message?
    page.has_css?("#no_questions")
  end

  def showing_project_dropdown?
    page.has_css?("#visit_project_id")
  end

  def showing_project_link?
    page.has_css?(".display-link")
  end

  private

  attr_reader :page, :reserve_id, :visit_id
end
