class CreateProjectFlow
  def initialize(page)
    @page = page
  end

  def visit_projects_page
    page.visit("/projects")
  end

  def visit_new_project_page
    page.visit("/projects/new")
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

  def has_selected_project_type?(name)
    page
      .first("label", text: name)
      .first(:xpath, ".//..")
      .has_css?("input:checked")
  end

  def showing_project_form?(name)
    type = name.downcase.tr(" ", "_")
    page.has_css?("form section.#{type}")
  end

  def select_project_type(name)
    page.first("label", text: name).click
  end

  private

  attr_reader :page
end
