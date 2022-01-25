require "rails_helper"

RSpec.describe Projects::FundingsController, type: :request do
  describe "/projects/:id/fundings" do
    it "renders the fundings page when the user is authorized" do
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

      get "/projects/#{project.id}/fundings"

      doc = Capybara.string(response.body)
      expect(response).to be_ok
      expect(doc).to have_css("body.fundings-index")
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

      get "/projects/#{project.id}/fundings"

      expect(response).to redirect_to(project_url(project))
    end
  end
end
