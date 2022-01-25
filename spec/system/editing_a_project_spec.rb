require "rails_helper"

RSpec.describe "Editing a project", type: :system, js: true do
  describe "when viewing the edit project form" do
    it "can edit an existing, fully filled-out project", js: true do
      user = create(:user, :confirmed)
      sign_in(user)
      project = create(
        :project,
        owner: user,
        applicant: user,
      )
      ptm = user.project_team_memberships.create(
        project: project,
        institution: create(:institution),
        user_role: :docent,
        can_edit_project: true,
        can_add_project_user: true,
      )
      institution = create(:institution, name: "MIT")
      another_user = create(
        :user,
        :confirmed,
        first_name: "Another",
        last_name: "User",
        role: :docent,
        email: "123@456.test",
        institution: institution
      )
      create(
        :permit,
        involves_fish: true,
        question: "Fish?",
        url1: "https://fish",
        url1_description: "About Fish"
      )
      create(:permit, involves_birds: true, question: "Birds?")
      flow = EditProjectFlow.new(page)

      flow.visit_project_edit_page(project)
      expect(page).to be_axe_clean

      expect(flow).to have_form_already_filled_out(
        title: project.title,
        thesis_title: project.thesis_title,
        abstract: project.abstract,
        project_type: project.project_type,
        start_date: project.start_date,
        end_date: project.end_date,
        discipline: project.discipline,
        discipline_other: project.discipline_other,
        involves_mammals: project.involves_mammals,
        involves_reptiles: project.involves_reptiles,
        involves_amphibians: project.involves_amphibians,
        involves_fish: project.involves_fish,
        involves_birds: project.involves_birds,
        involves_plants_fungi_soil: project.involves_plants_fungi_soil,
        involves_threatened_endangered_species: project.involves_threatened_endangered_species,
        involves_none: project.involves_none,
        method_description: project.method_description,
        method_study_area: project.method_study_area,
        method_remove_organisms: project.method_remove_organisms,
        method_transfer_organisms: project.method_transfer_organisms,
        method_study_non_native_species: project.method_study_non_native_species,
        method_chemicals: project.method_chemicals,
        method_chemicals_list: project.method_chemicals_list,
        method_soil_disturbance: project.method_soil_disturbance,
        method_long_term_structures: project.method_long_term_structures,
        keywords: project.keywords,
        taxonomic_keywords: project.taxonomic_keywords,
        recent_publications: project.recent_publications,
      )

      flow.fill_out_project_form(
        title: "Existing Project",
        thesis_title: "Projects that start out alreasdy created still exist",
        abstract: "This test, lol.",
        project_type: "research",
        start_date: Date.current + 10.days,
        end_date: Date.current + 20.days,
        discipline: "Other",
        discipline_other: "Accounting",
        involves_mammals: true,
        involves_reptiles: true,
        involves_amphibians: true,
        involves_fish: true,
        involves_birds: false,
        involves_plants_fungi_soil: true,
        involves_threatened_endangered_species: true,
        involves_none: true,
        method_description: "It takes 2 arguments: a string and a number",
        method_study_area: "My library",
        method_remove_organisms: "No",
        method_transfer_organisms: "No",
        method_study_non_native_species: "No",
        method_chemicals: "No",
        method_chemicals_list: "Oxygen?",
        method_soil_disturbance: "No",
        method_long_term_structures: "No",
        keywords: "Key, Lock, Pick, Tumbler",
        taxonomic_keywords: "Taxonomy, Category, Classification",
        recent_publications: "USA Today",
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

      flow.edit_team_member("First Last")
      flow.remove_team_member
      expect(flow).to have_no_team_member("Another User")

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

      flow.submit_team_memberships

      expect(flow).to be_allowed_to_view_project_permits_page
      expect(flow).to have_permit("Fish?")
      expect(flow).to have_no_permits("Birds?")

      flow.select_answer("Fish?", "Yes")
      expect(flow).to have_url_for_permit("Fish?", "About Fish" => "https://fish")
  
      flow.submit_step_three
      expect(flow).to be_allowed_to_view_project_fundings_page

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

      flow.edit_funding("Give me money for birdwatching")
      expect(flow).to be_showing_popup_editing_user("Give me money for birdwatching")
  
      flow.click_cancel
      expect(flow).to be_not_showing_popup_editing_user("Give me money for birdwatching")
  
      flow.edit_funding("Give me money for birdwatching")
      expect(flow).to be_showing_popup_editing_user("Give me money for birdwatching")

      flow.in_editing_modal do
        flow.fill_out_fundings_form(
          is_funded: true,
          title: "Give me money for birdwatching, please",
          principal_investigators: "Just me.",
          funding_sponsor: "Other",
          funding_sponsor_other: "Audubon Society",
          start_date: Date.new(2000, 12, 31),
          end_date: Date.new(2021, 1, 1),
          award_amount: "1000000.23",
        )
      end
      flow.submit_edit_funding
      expect(flow).to have_funding(
        title: "Give me money for birdwatching, please",
        funding_agency: "Audubon Society",
        award_amount: "$1,000,000.00"
      )
  
      flow.edit_funding("Give me money for birdwatching, please")
      flow.remove_funding
      expect(flow).to have_no_funding(
        title: "Give me money for birdwatching, please",
        funding_agency: "Audubon Society",
        award_amount: "$1,000,000.00"
      )
  
      flow.submit_step_four
      expect(flow).to be_on_project_summary_page
    end
  end
end
