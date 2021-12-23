require "rails_helper"

RSpec.describe "Creating a project", type: :system, js: true do
  describe "when viewing the new project form" do
    it "displays a dismissable modal on page load", js: true do
      user = create(:user, :confirmed)
      sign_in(user)
      flow = CreateProjectFlow.new(page)

      flow.visit_projects_page
      flow.click_create_new_project
      expect(flow).to have_modal_displayed
      expect(page).to be_axe_clean

      flow.dismiss_modal

      expect(flow).not_to have_modal_displayed
      expect(page).to be_axe_clean
    end
  end

  it "can switch between forms per-project_type" do
    user = create(:user, :confirmed)
    sign_in(user)
    flow = CreateProjectFlow.new(page)

    flow.visit_new_project_page
    flow.dismiss_modal
    expect(flow).to have_selected_project_type("Research")
    expect(flow).to be_showing_project_form("Research")

    flow.select_project_type("Meeting")
    expect(flow).to have_selected_project_type("Meeting")
    expect(flow).to be_showing_project_form("Meeting")
  end

  it "can create a new project" do
    user = create(:user, :confirmed)
    another_user = create(
      :user,
      :confirmed,
      first_name: "Another",
      last_name: "User",
      role: :docent,
      email: "123@456.test",
      institution: create(:institution, name: "MIT"),
    )
    sign_in(user)
    flow = CreateProjectFlow.new(page)

    flow.visit_new_project_page
    flow.dismiss_modal

    flow.fill_out_new_project_form(
      title: "Project Title",
      thesis_title: "Thesis Title",
      abstract: "Project Abstract",
      project_type: "research",
      start_date: Date.current,
      end_date: Date.current + 1.day,
      discipline: "Agriculture",
      discipline_other: nil,
      involves_mammals: nil,
      involves_reptiles: nil,
      involves_amphibians: nil,
      involves_fish: true,
      involves_birds: nil,
      involves_plants_fungi_soil: true,
      involves_threatened_endangered_species: nil,
      involves_none: nil,
      method_description: "Method Description",
      method_study_area: "Method Study Area",
      method_remove_organisms: "Yes",
      method_transfer_organisms: "Yes",
      method_study_non_native_species: "No",
      method_chemicals: "Yes",
      method_chemicals_list: "Chemicals List",
      method_soil_disturbance: "No",
      method_long_term_structures: "No",
      keywords: nil,
      taxonomic_keywords: nil,
      recent_publications: nil,
    )
    flow.submit_project_form
    expect(flow).to be_on_project_teams_page

    flow.click_create_new_user
    expect(flow).to be_showing_popup_creating_user

    flow.click_cancel
    expect(flow).to_not be_showing_popup_creating_user

    flow.enter_name_into_autocomplete("Anot")
    expect(flow).to be_showing_autocomplete_with_option("Another User - MIT - 1x3@456.test")

    flow.select_autocomplete_option("Another User")
    flow.select_project_role("Project Manager")
    flow.add_user_to_team
    expect(flow).to have_team_member("Another User")

    flow.edit_team_member("Another User")
    expect(flow).to be_showing_popup_editing_user("Another User")

    flow.change_users_role_to("Professional")
    flow.save_project_team_member
    flow.inexplicably_sleep_for_a_tiny_amount_of_time_because_wait_is_insufficient
    expect(flow).to_not be_showing_popup_editing_user("Another User")
    expect(flow).to be_showing_user_role_as("Professional", for_user: "Another User")
  end
end
