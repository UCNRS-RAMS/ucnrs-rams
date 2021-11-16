class CreateProjectFlow
  def initialize(page)
    @page = page
  end

  def visit_projects_page
    page.visit("/projects")
  end

  def click_create_new_project
    page.click_link("Create A New Project")
  end

  def dismiss_modal
    page.find(".modal button.active", text: "Okay, Got it").click
  end

  def has_modal_displayed?
    page.has_css?(".modal-content.project", visible: true)
  end

  private

  attr_reader :page
end
