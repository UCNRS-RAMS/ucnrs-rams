class Manager::VisitShowVisitorTabFlow
  def initialize(page:, visit_id:, reserve_id:)
    @page = page
    @visit_id = visit_id
    @reserve_id = reserve_id
  end

  # Go straight to the visitors step. The Turbo tab that links here is covered
  # by request specs; this flow keeps only the autocomplete/Turbo behavior that
  # actually needs a browser.
  def visit_user_visits_page
    page.visit("/manager/reserves/#{reserve_id}/visits/#{visit_id}/user_visits")
  end

  def click_on_add_individual
    page.click_link("Add Individual")
  end

  def set_guest
    page.find("#user_visit_guest_name").set("John")
  end

  def select_option
    page.find(".autocomplete-results [role='option']", match: :first).click
  end

  def click_add_visitor
    page.click_button("Add Visitor")
  end

  private

  attr_reader :page, :reserve_id, :visit_id
end
