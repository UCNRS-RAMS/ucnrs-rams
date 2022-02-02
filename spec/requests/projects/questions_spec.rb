require "rails_helper"

RSpec.describe Projects::QuestionsController, type: :request do
  describe "/projects/:id/questions" do
    it "renders the questions page when the user is authorized" do
      user = create(:user, :confirmed)
      sign_in(user)
      project = create(:project)
      membership = create(
        :project_team_membership,
        user: user,
        project: project,
        active: true,
        can_edit_project: true,
      )

      get "/projects/#{project.id}/questions"

      doc = Capybara.string(response.body)
      expect(response).to be_ok
      expect(doc).to have_css("body.questions-index")
    end

    it "redirects to the project summary page when the user is not authorized" do
      user = create(:user, :confirmed)
      sign_in(user)
      project = create(:project)
      membership = create(
        :project_team_membership,
        user: user,
        project: project,
        active: true,
        can_edit_project: false,
      )

      get "/projects/#{project.id}/questions"

      expect(response).to redirect_to(project_url(project))
    end
  end
end
