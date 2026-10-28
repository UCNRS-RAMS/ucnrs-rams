require "rails_helper"

RSpec.describe Manager::Projects::TeamMembershipsController, type: :request do
  let(:user) { create(:user, :confirmed) }
  let(:reserve) { create(:reserve) }
  let(:project) { create(:project, reserve: reserve, owner: user) }

  before { create(:reserve_personnel, user: user, reserve: reserve) }

  describe "GET /manager/reserves/:reserve_id/projects/:project_id/team_memberships" do
    it "renders the add team member form and the team member table" do
      owner_membership = create(
        :project_team_membership,
        :principal_investigator,
        project: project,
        user: user,
      )
      team_membership = create(
        :project_team_membership,
        :principal_investigator,
        project: project,
        user: create(:user),
      )
      sign_in(user)

      get "/manager/reserves/#{reserve.id}/projects/#{project.id}/team_memberships"

      doc = Capybara.string(response.body)
      expect(response).to be_ok
      expect(doc).to have_css("#add-user-form")
      expect(doc).to have_field("project_team_membership[full_name]")
      expect(doc).to have_css("input#project_team_membership_user_id", visible: :all)
      expect(doc).to have_css("#project-role-select select")
      expect(doc).to have_css(".team-member-section")
      expect(doc).to have_css("table.team-member-table")
      expect(doc).to have_link(
        href: "/manager/reserves/#{reserve.id}/team_memberships/#{team_membership.id}/edit",
      )
      expect(doc).to have_no_link(
        href: "/manager/reserves/#{reserve.id}/team_memberships/#{owner_membership.id}/edit",
      )
    end
  end
end
