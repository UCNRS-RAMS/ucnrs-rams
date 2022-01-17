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

  def has_no_modal_displayed?
    page.has_no_css?(".modal-content.project", visible: true)
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

  def fill_out_new_project_form(
    title:,
    thesis_title:,
    abstract:,
    project_type:,
    start_date:,
    end_date:,
    discipline:,
    discipline_other:,
    involves_mammals:,
    involves_reptiles:,
    involves_amphibians:,
    involves_fish:,
    involves_birds:,
    involves_plants_fungi_soil:,
    involves_threatened_endangered_species:,
    involves_none:,
    method_description:,
    method_study_area:,
    method_remove_organisms:,
    method_transfer_organisms:,
    method_study_non_native_species:,
    method_chemicals:,
    method_chemicals_list:,
    method_soil_disturbance:,
    method_long_term_structures:,
    keywords:,
    taxonomic_keywords:,
    recent_publications:
  )
    page.fill_in("Project or Event Title", with: title)
    page.fill_in("Thesis Title", with: thesis_title)
    page.fill_in("Project Abstract", with: abstract)
    page.choose(discipline)
    if discipline == "Other"
      page.fill_in("dicipline_other", with: discipline_other)
    end
    page.check("Mammals") if involves_mammals
    page.check("Reptiles") if involves_reptiles
    page.check("Amphibians") if involves_amphibians
    page.check("Fish") if involves_fish
    page.check("Birds") if involves_birds
    page.check("Plants, Fungi, or Soils") if involves_plants_fungi_soil
    page.check("Threatened, Endangered, or Species of Special Concern") if involves_threatened_endangered_species
    page.check("None of the Above") if involves_none
    page.fill_in("Start Date", with: start_date)
    page.fill_in("End Date", with: end_date)
    page.fill_in("Project Keywords (Optional)", with: keywords)
    page.fill_in("Taxonomic Keywords (Optional)", with: taxonomic_keywords)
    page.fill_in("Recent Publications (Optional)", with: recent_publications)
    page.fill_in("Environmental Manipulations Needed", with: method_description)
    page.fill_in("Describe where you will be working on the reserve.", with: method_study_area)
    page.choose("project_method_remove_organisms_#{method_remove_organisms.downcase}")
    page.choose("project_method_transfer_organisms_#{method_transfer_organisms.downcase}")
    page.choose("project_method_study_non_native_species_#{method_study_non_native_species.downcase}")
    page.choose("project_method_chemicals_#{method_chemicals.downcase}")
    if method_chemicals == "Yes"
      page.fill_in("project_method_chemicals_list", with: method_chemicals_list)
    end
    page.choose("project_method_soil_disturbance_#{method_soil_disturbance.downcase}")
    page.choose("project_method_long_term_structures_#{method_long_term_structures.downcase}")
  end

  def submit_project_form
    page.find("button[form='projects-new']").click
  end

  def on_project_teams_page?
    page.has_css?("body.team_memberships-index")
  end

  def enter_name_into_autocomplete(text)
    page.fill_in("project_team_membership_full_name", with: text)
  end

  def showing_autocomplete_with_option?(option_name)
    page.has_css?(".autocomplete-results li", text: option_name)
  end

  def select_autocomplete_option(option)
    page.find(".autocomplete-results li", text: option).click
  end

  def select_project_role(option)
    page.select(option, from: "Project Role")
  end

  def add_user_to_team
    page.find("input[value='Add Team Member']").click
  end

  def has_team_member?(name)
    page.has_css?("tr.team-membership td", text: name)
  end

  def has_no_team_member?(name)
    page.has_no_css?("tr.team-membership td", text: name)
  end

  def edit_team_member(name)
    page
      .find("td", text: name)
      .first(:xpath, ".//..")
      .find("a", text: "Edit")
      .click
  end

  def showing_popup_editing_user?(name)
    page.has_css?(".modal.visible h2", text: name)
  end

  def not_showing_popup_editing_user?(name)
    page.has_no_css?(".modal.visible h2", text: name)
  end

  def save_project_team_member
    page.find(".modal.visible .buttons button").click
    page.has_no_css?(".modal.visible")
  end

  def change_users_role_to(role)
    page.select(role, from: "User role")
  end

  def showing_user_role_as?(role, for_user:)
    page
      .find("td", text: for_user)
      .first(:xpath, ".//..")
      .has_css?("td", text: role)
  end

  def remove_team_member
    page.accept_confirm do
      page.find(".modal.visible a[data-method='delete']").click
    end
  end

  def click_create_new_user
    page.click_link("Create new user")
  end

  def showing_popup_creating_user?
    page.has_css?(".modal.visible h2", text: "Create a New User")
  end

  def not_showing_popup_creating_user?
    page.has_no_css?(".modal.visible h2", text: "Create a New User")
  end

  def create_user_with_membership(
    first_name: "A first name",
    last_name: "And a last name",
    email: "foo@email.test",
    user_role: "Other",
    project_role: "PI - Principal Investigator",
    institution: nil
  )
    page.fill_in("First name", with: first_name)
    page.fill_in("Last name", with: last_name)
    page.fill_in("Institution name", with: institution.name)
    page.find("li#institution_#{institution.id}").click
    page.fill_in("Email", with: email)
    page.select(user_role, from: "User role")
    page.select(project_role, from: "Project role")
  end

  def submit_step_two
    page.find("form.button_to button").click
  end

  def on_project_permits_page?
    page.has_css?("body.permits-index")
  end

  def has_permit?(exact_title)
    page.has_css?(".question", text: exact_title)
  end

  def has_no_permits?(exact_title)
    page.has_no_css?(".question", text: exact_title)
  end

  def select_answer(question, answer)
    page
      .find(".question", text: question)
      .find(".answers label", text: answer)
      .click
  end

  def has_url_for_permit?(question, urls)
    urls.all? do |text, url|
      page
        .find(".question", text: question)
        .first(:xpath, ".//..")
        .has_css?(".description a[href='#{url}']", text: text, visible: true)
    end
  end

  def submit_step_three
    page.find("button[form='project-permits']").click
  end

  def on_project_fundings_page?
    page.has_css?("body.fundings-index")
  end

  def submit_step_four
    page.find("form.button_to button").click
  end

  def on_project_summary_page?
    page.has_css?("body.projects-show")
  end

  private

  attr_reader :page
end
