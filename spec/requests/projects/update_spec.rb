require "rails_helper"

RSpec.describe ProjectsController, type: :request do
  describe "PATCH /projects/:id" do
    it "updates the project and advances to the team step" do
      user = create(:user, :confirmed)
      project = create(:project, owner: user, applicant: user, status: :open)
      create(
        :project_team_membership,
        project: project,
        user: user,
        active: true,
        can_edit_project: true,
      )
      sign_in(user)

      patch "/projects/#{project.id}", params: {
        project: {
          title: "Updated Title",
          abstract: "Updated Abstract",
          method_description: "Updated Method"
        }
      }

      project.reload
      expect(response).to redirect_to(project_team_memberships_path(project, format: :html))
      expect(project.title).to eq "Updated Title"
      expect(project.abstract).to eq "Updated Abstract"
      expect(project.method_description).to eq "Updated Method"
    end

    it "redirects to the project when the user cannot edit it" do
      user = create(:user, :confirmed)
      project = create(:project)
      create(
        :project_team_membership,
        project: project,
        user: user,
        active: true,
        can_edit_project: false,
      )
      sign_in(user)

      patch "/projects/#{project.id}", params: { project: { title: "Updated Title" } }

      expect(response).to redirect_to(project_path(project))
      expect(flash[:alert]).to eq I18n.t("projects.not_authorized")
      expect(project.reload.title).not_to eq "Updated Title"
    end

    it "redirects a user who is not on the project team" do
      user = create(:user, :confirmed)
      project = create(:project)
      sign_in(user)

      patch "/projects/#{project.id}", params: { project: { title: "Updated Title" } }

      expect(response).to redirect_to(home_index_path)
      expect(flash[:alert]).to eq "You are not authorized."
      expect(project.reload.title).not_to eq "Updated Title"
    end
  end
end
