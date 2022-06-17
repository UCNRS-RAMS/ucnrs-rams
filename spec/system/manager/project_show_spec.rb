require "rails_helper"

RSpec.describe "Manager Project Show" do
  let(:user)    { create(:user, :confirmed) }
  let(:reserve) { create(:reserve, name: "Test Reserve") }
  let(:project) { create(:project, reserve: reserve) }

  describe "it displays project show page" do
    it "includes summary box and menu bar", js: true do
      sign_in(user)
      flow = ProjectShowFlow.new(page: page, project_id: project.id, reserve_id: reserve.id)

      flow.visit_show_page

      expect(flow).to be_showing_summary_box
      expect(flow).to be_showing_menu_bar
    end
  end

  describe "it includes project visits section" do
    it "includes rows in project visits table", js: true do
      create_list(:visit, 3, project: project)
      sign_in(user)
      flow = ProjectShowFlow.new(page: page, project_id: project.id, reserve_id: reserve.id)

      flow.visit_show_page
      flow.click_on_visits

      expect(flow).to have_section("project-visits")
      expect(flow).to have_n_table_rows(css_class: ".project-visits", count: 3)
    end

    it "includes visit values in table row", js: true do
      create(:visit, project: project, reserve: reserve)
      sign_in(user)
      flow = ProjectShowFlow.new(page: page, project_id: project.id, reserve_id: reserve.id)

      flow.visit_show_page
      flow.click_on_visits

      flow.in_visits_section do
        expect(flow).to have_table_data_text(child: 1, text: "INCOMPLETE")
        expect(flow).to have_table_data_text(child: 3, text: "Test Reserve")
      end
    end
  end

  describe "includes project team section" do
    it "has team summary table" do
      create_list(:project_team_membership, 3, project: project)

      sign_in(user)
      flow = ProjectShowFlow.new(page: page, project_id: project.id, reserve_id: reserve.id)

      flow.visit_show_page
      flow.click_on_summary

      expect(flow).to have_section("project-team")
      expect(flow).to have_navigation_link("Edit Team")
      expect(flow).to be_showing_summary_table
      expect(flow).to have_no_inactive_user
    end

    it "includes inactive user class" do
      create(:project_team_membership, project: project, active: false)

      sign_in(user)
      flow = ProjectShowFlow.new(page: page, project_id: project.id, reserve_id: reserve.id)

      flow.visit_show_page
      flow.click_on_summary

      expect(flow).to have_inactive_user
    end
  end

  it "includes project funding section" do
    sign_in(user)
    flow = ProjectShowFlow.new(page: page, project_id: project.id, reserve_id: reserve.id)
    
    flow.visit_show_page
    flow.click_on_summary

    expect(flow).to have_section("project-funding")
    expect(flow).to have_navigation_link("Edit Funding")
    expect(flow).to be_showing_funding_summary_table
  end

  it "includes project permit section" do
    sign_in(user)
    flow = ProjectShowFlow.new(page: page, project_id: project.id, reserve_id: reserve.id)

    flow.visit_show_page
    flow.click_on_summary

    expect(flow).to have_section("project-permit")
    expect(flow).to have_navigation_link("Edit Permits")
    expect(flow).to be_showing_permit_summary_list
  end

  it "includes project short info" do
    project = create(
      :project,
      reserve: reserve,
      project_type: :research,
      status: :incomplete,
      created_at: Time.zone.local(2004, 11, 24, 1, 4, 44),
      reserve: reserve,
    )
    sign_in(user)
    flow = ProjectShowFlow.new(page: page, project_id: project.id, reserve_id: reserve.id)
    flow.visit_show_page
    flow.click_on_summary

    expected_info = "Incomplete Research Project Created: Nov. 24, 2004 at 1:04 AM"
    expect(flow).to be_showing_text(expected_info)
  end

  describe "it displays manager's project detail section in show page" do
    it "renders research form", js: true do
      project = create(:project, reserve: reserve, project_type: "research")

      sign_in(user)
      flow = ProjectShowFlow.new(page: page, project_id: project.id, reserve_id: reserve.id)

      flow.visit_show_page

      expect(flow).to be_not_showing_form(".research")
      flow.click_on_details
      expect(flow).to be_showing_text("Field or lab base research in any discipline")
      expect(flow).to have_heading("Research")
      expect(flow).to be_showing_form(".research")
    end

    it "renders meeting form", js: true do
      project = create(:project, reserve: reserve, project_type: "meeting")

      sign_in(user)
      flow = ProjectShowFlow.new(page: page, project_id: project.id, reserve_id: reserve.id)

      flow.visit_show_page

      expect(flow).to be_not_showing_form(".meeting")
      flow.click_on_details
      expect(flow).to be_showing_text("Field or lab base meeting in any discipline")
      expect(flow).to have_heading("Meeting")
      expect(flow).to be_showing_form(".meeting")
    end

    it "renders class form", js: true do
      project = create(:project, reserve: reserve, project_type: "class")

      sign_in(user)
      flow = ProjectShowFlow.new(page: page, project_id: project.id, reserve_id: reserve.id)

      flow.visit_show_page

      expect(flow).to be_not_showing_form(".class")
      flow.click_on_details
      expect(flow).to be_showing_text("Field or lab base class in any discipline")
      expect(flow).to have_heading("Class")
      expect(flow).to be_showing_form(".class")
    end

    describe "it includes fundings section", js: true do
      let(:user) { create(:user, :confirmed) }
      let(:reserve) { create(:reserve) }
      let(:project) { create(:project, reserve: reserve) }

      it "renders fundings partial" do
        create(:reserve_personnel, user: user, reserve: reserve)
        sign_in(user)
        flow = ProjectShowFlow.new(page: page, project_id: project.id, reserve_id: reserve.id)

        flow.visit_show_page

        expect(flow).to be_not_showing_fundings
        flow.click_on_fundings
        expect(flow).to be_showing_fundings
      end

      it "displays a form to edit a funding" do
        create(:reserve_personnel, user: user, reserve: reserve)
        create(:funding, project: project)

        sign_in(user)
        flow = ProjectShowFlow.new(page: page, project_id: project.id, reserve_id: reserve.id)

        flow.visit_show_page
        flow.click_on_fundings

        within(".funding-table") do
          flow.click_on_funding_edit
        end
        expect(flow).to be_showing_funding_edit_modal
      end
    end

    it "renders permit questions partial", js: true do
      user = create(:user, :confirmed)
      reserve = create(:reserve)
      project = create(:project, involves_mammals: true, reserve: reserve)
      permit = create(:permit, involves_all: true)

      sign_in(user)
      flow = ProjectShowFlow.new(page: page, project_id: project.id, reserve_id: reserve.id)

      flow.visit_show_page

      expect(flow).to be_not_showing_questions
      flow.click_on_permits
      expect(flow).to be_showing_questions
    end
  end

  describe "it displays manager's project team section in show page" do
    it "displays a form to add a project team member" do
      user = create(:user, :confirmed)
      reserve = create(:reserve)
      project = create(:project, owner: user)
      team_membership = create(:project_team_membership, :principal_investigator, project: project,
        user: user)

      sign_in(user)
      flow = ProjectShowFlow.new(page: page, project_id: project.id, reserve_id: reserve.id)

      flow.visit_show_page

      expect(flow).to be_not_showing_form("#add-user-form")
      flow.click_on_team
      expect(flow).to have_text_field("project_team_membership_full_name")
      expect(flow).to have_hidden_field("project_team_membership_user_id")
      expect(flow).to have_select_field("Project Role")
      expect(flow).to have_section("team-member-table")
      expect(flow).to have_team_membership_edit_link(team_membership.id)
    end

    it "displays a team member table" do
      user = create(:user, :confirmed)
      reserve = create(:reserve)
      project = create(:project, owner: user)
      team_membership = create(:project_team_membership, :principal_investigator, project: project,
        user: user)

      sign_in(user)
      flow = ProjectShowFlow.new(page: page, project_id: project.id, reserve_id: reserve.id)

      flow.visit_show_page

      expect(flow).to be_not_showing_form(".team-member-table")
      flow.click_on_team
      expect(flow).to be_showing_form(".team-member-table")
      expect(flow).to have_team_membership_edit_link(team_membership.id)
    end

    describe "if the user does not have can_add_project_user permission" do
      it "does not show the add user form" do
        user = create(:user, :confirmed)
        reserve = create(:reserve)
        project = create(:project, owner: user)
        create(:project_team_membership, :team_member, project: project)

        sign_in(user)
        flow = ProjectShowFlow.new(page: page, project_id: project.id, reserve_id: reserve.id)

        flow.visit_show_page
        flow.click_on_team
        expect(flow).to be_not_showing_form("#add-user-form")
        expect(flow).to be_not_showing_section("team-member-table")
      end
    end
  end
end
