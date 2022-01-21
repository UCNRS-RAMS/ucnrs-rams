require "rails_helper"

RSpec.describe ProjectsController, type: :request do
  describe "/projects/:id/edit" do
    it "renders the edit form when the user is authorized" do
      user = create(:user, :confirmed)
      sign_in(user)
      project = create(:project)
      membership = create(
        :project_team_membership,
        user: user,
        project: project,
        can_edit_project: true,
      )

      get "/projects/#{project.id}/edit"

      doc = Capybara.string(response.body)
      expect(response).to be_ok
      expect(doc).to have_css("body.projects-edit")
    end

    it "redirects when the user is not authorized" do
      user = create(:user, :confirmed)
      sign_in(user)
      project = create(:project)
      membership = create(
        :project_team_membership,
        user: user,
        project: project,
        can_edit_project: false,
      )

      get "/projects/#{project.id}/edit"

      expect(response).to redirect_to(project_url(project))
    end
  end
end
