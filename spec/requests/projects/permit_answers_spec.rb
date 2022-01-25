require "rails_helper"

RSpec.describe Projects::PermitAnswersController, type: :request do
  describe "/projects/:id/permit_answers" do
    it "does not error when there are no permit answers" do
      user = create(:user, :confirmed)
      project = create(:project, title: "Project 1", project_type: "Research")
      create(
        :project_team_membership,
        user: user,
        project: project,
        active: true,
        can_edit_project: true,
      )
      sign_in(user)

      post "/projects/#{project.id}/permit_answers", params: { project: { no_permits: "" } }
      follow_redirect!

      page = Capybara.string(response.body)
      expect(response).to be_ok
      expect(page).to have_css(".fundings-index")
    end

    it "allows permit creation when the user is authorized" do
      user = create(:user, :confirmed)
      sign_in(user)
      project = create(:project)
      create(
        :project_team_membership,
        user: user,
        project: project,
        active: true,
        can_edit_project: true,
      )

      post "/projects/#{project.id}/permit_answers", params: { project: { no_permits: "" } }
      follow_redirect!

      doc = Capybara.string(response.body)
      expect(response).to be_ok
      expect(doc).to have_css(".fundings-index")
    end

    it "redirects to the project summary page when the user is not authorized" do
      user = create(:user, :confirmed)
      sign_in(user)
      project = create(:project)
      create(
        :project_team_membership,
        user: user,
        project: project,
        active: true,
        can_edit_project: false,
      )

      post "/projects/#{project.id}/permit_answers", params: { project: { no_permits: "" } }

      expect(response).to redirect_to(project_url(project))
    end
  end
end
