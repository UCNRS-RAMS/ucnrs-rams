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

  def showing_summary_partial?
    page.has_css?(".summary")
  end

  def click_on_trash_icon
    page.accept_confirm do
      page.find("#trash-icon").click
    end
  end

  private

  attr_reader :page, :reserve_id, :visit_id
end
