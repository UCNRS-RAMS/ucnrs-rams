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

      expect(flow).to have_no_modal_displayed
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
    institution = create(:institution, name: "MIT")
    user = create(:user, :confirmed)
    another_user = create(
      :user,
      :confirmed,
      first_name: "Another",
      last_name: "User",
      role: :docent,
      email: "123@456.test",
      institution: institution
    )
    sign_in(user)
    create(
      :permit,
      involves_fish: true,
      question: "Fish?",
      url1: "https://fish",
      url1_description: "About Fish"
    )
    create(:permit, involves_birds: true, question: "Birds?")
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

    flow.create_user_with_membership(
      first_name: "First",
      last_name: "Last",
      institution: institution
    )
    flow.save_project_team_member
    expect(flow).to be_not_showing_popup_creating_user
    expect(flow).to have_team_member("First Last")

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
    expect(flow).to be_not_showing_popup_editing_user("Another User")
    expect(flow).to be_showing_user_role_as("Professional", for_user: "Another User")

    flow.edit_team_member("Another User")
    flow.remove_team_member
    expect(flow).to have_no_team_member("Another User")

    flow.submit_step_two
    expect(flow).to be_on_project_permits_page
    expect(flow).to have_permit("Fish?")
    expect(flow).to have_no_permits("Birds?")

    flow.select_answer("Fish?", "Yes")
    expect(flow).to have_url_for_permit("Fish?", "About Fish" => "https://fish")

    flow.submit_step_three
    expect(flow).to be_on_project_fundings_page

    flow.fill_out_fundings_form(
      title: "Give me money for birdwatching",
      principal_investigators: "Avery Visage",
      funding_sponsor: "Other",
      funding_sponsor_other: "Audubon",
      start_date: Date.new(2000, 12, 31),
      end_date: Date.new(2021, 1, 1),
      award_amount: "1000000.00",
    )
    flow.submit_new_funding
    expect(flow).to be_on_project_fundings_page
    expect(flow).to have_funding(
      title: "Give me money for birdwatching",
      funding_agency: "Audubon",
      award_amount: "$1,000,000.00"
    )

    flow.submit_step_four
    expect(flow).to be_on_project_summary_page
  end
end
