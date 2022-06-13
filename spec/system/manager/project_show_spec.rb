require "rails_helper"

RSpec.describe "Manager Project Show" do
  describe "it displays project show page" do
    it "includes summary box and menu bar", js: true do
      user = create(:user, :confirmed)
      reserve = create(:reserve)
      project = create(:project)

      sign_in(user)
      flow = ProjectShowFlow.new(page: page, project_id: project.id, reserve_id: reserve.id)

      flow.visit_show_page

      expect(page).to have_css(".project-summary-box")
      expect(page).to have_css(".project-menu-bar")
    end
  end

  describe "includes project team section" do
    it "has team summary table" do
      user = create(:user, :confirmed)
      reserve = create(:reserve)
      project = create(:project)
      create_list(:project_team_membership, 3, project: project)

      sign_in(user)
      flow = ProjectShowFlow.new(page: page, project_id: project.id, reserve_id: reserve.id)

      flow.visit_show_page
      flow.click_on_summary

      expect(page).to have_css("section.project-team")
      expect(page).to have_css("a", text: "Edit Team")
      expect(page).to have_css("table#team-summary-table")
      expect(page).to_not have_css(".inactive-user")
    end

    it "includes inactive user class" do
      user = create(:user, :confirmed)
      reserve = create(:reserve)
      project = create(:project)
      create(:project_team_membership, project: project, active: false)

      sign_in(user)
      flow = ProjectShowFlow.new(page: page, project_id: project.id, reserve_id: reserve.id)

      flow.visit_show_page
      flow.click_on_summary

      expect(page).to have_css(".inactive-user")
    end
  end

  it "includes project funding section" do
    user = create(:user, :confirmed)
    reserve = create(:reserve)
    project = create(:project)

    sign_in(user)
    flow = ProjectShowFlow.new(page: page, project_id: project.id, reserve_id: reserve.id)
    flow.visit_show_page
    flow.click_on_summary

    expect(page).to have_css("section.project-funding")
    expect(page).to have_css("a", text: "Edit Funding")
    expect(page).to have_css("table#funding-summary-table")
  end

  it "includes project permit section" do
    user = create(:user, :confirmed)
    reserve = create(:reserve)
    project = create(:project)

    sign_in(user)
    flow = ProjectShowFlow.new(page: page, project_id: project.id, reserve_id: reserve.id)
    flow.visit_show_page
    flow.click_on_summary

    expect(page).to have_css("section.project-permit")
    expect(page).to have_css("a", text: "Edit Permits")
    expect(page).to have_css("div#permit-summary-list")
  end

  it "includes project short info" do
    user = create(:user, :confirmed)
    reserve = create(:reserve)
    project = create(
      :project,
      project_type: :research,
      status: :incomplete,
      created_at: Time.zone.local(2004, 11, 24, 1, 4, 44),
    )
    sign_in(user)
    flow = ProjectShowFlow.new(page: page, project_id: project.id, reserve_id: reserve.id)
    flow.visit_show_page
    flow.click_on_summary

    expected_info = "Incomplete Research Project Created: Nov. 24, 2004 at 1:04 AM"
    expect(page).to have_css("p", text: expected_info)
  end

  describe "it displays manager's project detail section in show page" do
    it "renders research form", js: true do
      user = create(:user, :confirmed)
      reserve = create(:reserve)
      project = create(:project, project_type: "research")

      sign_in(user)
      flow = ProjectShowFlow.new(page: page, project_id: project.id, reserve_id: reserve.id)

      flow.visit_show_page

      expect(page).to_not have_css(".research")
      flow.click_on_details
      expect(page).to have_css("p", text: "Field or lab base research in any discipline")
      expect(page).to have_css("h3", text: "Research")
      expect(page).to have_css(".research")
    end

    it "renders meeting form", js: true do
      user = create(:user, :confirmed)
      reserve = create(:reserve)
      project = create(:project, project_type: "meeting")

      sign_in(user)
      flow = ProjectShowFlow.new(page: page, project_id: project.id, reserve_id: reserve.id)

      flow.visit_show_page

      expect(page).to_not have_css(".meeting")
      flow.click_on_details
      expect(page).to have_css("p", text: "Field or lab base meeting in any discipline")
      expect(page).to have_css("h3", text: "Meeting")
      expect(page).to have_css(".meeting")
    end

    it "renders class form", js: true do
      user = create(:user, :confirmed)
      reserve = create(:reserve)
      project = create(:project, project_type: "class")

      sign_in(user)
      flow = ProjectShowFlow.new(page: page, project_id: project.id, reserve_id: reserve.id)

      flow.visit_show_page

      expect(page).to_not have_css(".class")
      flow.click_on_details
      expect(page).to have_css("p", text: "Field or lab base class in any discipline")
      expect(page).to have_css("h3", text: "Class")
      expect(page).to have_css(".class")
    end
  end
end
