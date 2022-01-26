require "rails_helper"

RSpec.describe Projects::TeamMembershipsController, type: :request do
  describe "#index" do
    it "allows users that have the can_add_project_user permission" do
      user = create(:user, :confirmed)
      membership = create(
        :project_team_membership,
        can_add_project_user: true,
        can_edit_project: false,
        user: user)
      sign_in(user)

      get "/projects/#{membership.project.id}/team_memberships"

      expect(response).to be_ok
    end

    it "allows users that have the can_edit_project permission" do
      user = create(:user, :confirmed)
      membership = create(
        :project_team_membership,
        can_add_project_user: false,
        can_edit_project: true,
        user: user)
      sign_in(user)

      get "/projects/#{membership.project.id}/team_memberships"

      expect(response).to be_ok
    end

    it "disallows users without can_edit_project or can_add_project_user" do
      user = create(:user, :confirmed)
      membership = create(
        :project_team_membership,
        can_add_project_user: false,
        can_edit_project: false,
        user: user
      )
      sign_in(user)

      get "/projects/#{membership.project.id}/team_memberships"

      expect(response).to redirect_to("/projects/#{membership.project.id}")
    end
  end

  describe "#create" do
    it "is allowed if the user has can_add_project_user permission" do
      user = create(:user, :confirmed)
      membership = create(
        :project_team_membership,
        can_add_project_user: true,
        user: user)
      sign_in(user)

      post "/projects/#{membership.project.id}/team_memberships", params: {
        project_team_membership:
          attributes_for(:project_team_membership, project: membership.project)
      }

      expect(response).to_not be_unauthorized
    end

    it "is not allowed if the user does not have can_add_project_user" do
      user = create(:user, :confirmed)
      membership = create(
        :project_team_membership,
        can_add_project_user: false,
        user: user)
      sign_in(user)

      post "/projects/#{membership.project.id}/team_memberships", params: {
        project_team_membership:
          attributes_for(:project_team_membership, project: membership.project)
      }

      expect(response).to be_unauthorized
    end
  end

  describe "#edit" do
    it "is allowed if the user has can_edit_project permission" do
      user = create(:user, :confirmed)
      membership = create(
        :project_team_membership,
        can_edit_project: true,
        user: user)
      sign_in(user)

      get "/team_memberships/#{membership.id}/edit"

      expect(response).to_not be_unauthorized
    end

    it "is not allowed if the user does not have can_edit_project" do
      user = create(:user, :confirmed)
      membership = create(
        :project_team_membership,
        can_edit_project: false,
        user: user)
      sign_in(user)

      get "/team_memberships/#{membership.id}/edit"

      expect(response).to be_unauthorized
    end
  end

  describe "#update" do
    it "is allowed if the user has can_edit_project permission" do
      user = create(:user, :confirmed)
      membership = create(
        :project_team_membership,
        can_edit_project: true,
        user: user)
      sign_in(user)

      put "/team_memberships/#{membership.id}", params: {
        project_team_membership: {
          id: membership.id,
          **attributes_for(:project_team_membership, project: membership.project)
        }
      }

      expect(response).to_not be_unauthorized
    end

    it "is not allowed if the user does not have can_edit_project" do
      user = create(:user, :confirmed)
      membership = create(
        :project_team_membership,
        can_edit_project: false,
        user: user)
      sign_in(user)

      put "/team_memberships/#{membership.id}", params: {
        project_team_membership: {
          id: membership.id,
          **attributes_for(:project_team_membership, project: membership.project)
        }
      }

      expect(response).to be_unauthorized
    end
  end

  describe "#destroy" do
    it "is allowed if the user has can_edit_project permission" do
      user = create(:user, :confirmed)
      membership = create(
        :project_team_membership,
        can_edit_project: true,
        user: user)
      sign_in(user)

      delete "/team_memberships/#{membership.id}"

      expect(response).to_not be_unauthorized
    end

    it "is not allowed if the user does not have can_edit_project" do
      user = create(:user, :confirmed)
      membership = create(
        :project_team_membership,
        can_edit_project: false,
        user: user)
      sign_in(user)

      put "/team_memberships/#{membership.id}"

      expect(response).to be_unauthorized
    end
  end
end
