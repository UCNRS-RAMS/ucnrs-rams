require "rails_helper"

RSpec.describe Visits::ProjectsController, type: :request do
  describe "/visits/projects" do
    it "returns projects as a select dropdown" do
      user = create(:user, :confirmed)
      project = create(:project, title: "Project 1", project_type: "Research")
      create(:project_team_membership, user: user, project: project, active: true, can_add_visit: true)
      sign_in(user)

      get "/visits/projects?project_type=research"

      page = Capybara.string(response.body)
      expect(page).to have_select(
        "visit_project_id",
        selected: nil,
        with_options: ["Project 1"]
      )
    end

    it "returns project select with the 'project_id' selected" do
      user = create(:user, :confirmed)
      project = create(:project, title: "Project 1", project_type: "Research")
      create(:project_team_membership, user: user, project: project, active: true, can_add_visit: true)
      sign_in(user)

      get "/visits/projects?project_type=research&project_id=#{project.id}"

      page = Capybara.string(response.body)
      expect(page).to have_select("visit_project_id", selected: "Research - Project 1")
    end
  end
end
