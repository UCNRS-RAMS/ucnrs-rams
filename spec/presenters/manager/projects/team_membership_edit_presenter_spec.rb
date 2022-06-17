require "rails_helper"

RSpec.describe Manager::Projects::TeamMembershipEditPresenter do
  describe "#able_to_change_owner?" do
    it "returns true for edit team membership when the user is the reserve manager" do
      user = create(:user, :confirmed)
      reserve_personnel = create(:reserve_personnel, user: user)
      project = create(:project, owner: user, reserve: reserve_personnel.reserve)
      membership = create(:project_team_membership, :principal_investigator, project: project,
        user: user)

      form = ProjectTeamMembershipForm.new(params: { id: membership.id })
      presenter = Manager::Projects::TeamMembershipEditPresenter.new(form: form, user: user)

      expect(presenter.able_to_change_owner?).to eq true
    end

    it "returns false for edit team membership when the user is not the reserve manager" do
      user = create(:user, :confirmed)
      project = create(:project, owner: user)
      membership = create(:project_team_membership, :principal_investigator, project: project,
        user: user)

      form = ProjectTeamMembershipForm.new(params: { id: membership.id })
      presenter = Manager::Projects::TeamMembershipEditPresenter.new(form: form, user: user)

      expect(presenter.able_to_change_owner?).to eq false
    end
  end

  describe "#team_memberships_form_path" do
    it "returns the path for team membership" do
      user = create(:user, :confirmed)
      membership = create(:project_team_membership)
      form = ProjectTeamMembershipForm.new(params: { id: membership.id })
      presenter = Manager::Projects::TeamMembershipEditPresenter.new(form: form, user: user)

      expect(presenter.team_memberships_form_path).to eq "/manager/team_memberships/#{membership.id}"
    end
  end
end
