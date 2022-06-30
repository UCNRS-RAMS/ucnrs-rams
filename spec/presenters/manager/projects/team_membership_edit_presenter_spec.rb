require "rails_helper"

RSpec.describe Manager::Projects::TeamMembershipEditPresenter do
  describe "#able_to_change_owner?" do
    it "returns true for edit team membership when the user is the reserve manager" do
      user = create(:user, :confirmed)
      reserve = create(:reserve)
      create(:reserve_personnel, user: user, reserve: reserve)
      project = create(:project, owner: user, reserve: reserve)
      membership = create(:project_team_membership, :principal_investigator, project: project,
        user: user)

      form = ProjectTeamMembershipForm.new(params: { id: membership.id })
      presenter = Manager::Projects::TeamMembershipEditPresenter.new(form: form, reserve: reserve)

      expect(presenter.able_to_change_owner?).to eq true
    end
  end

  describe "#team_memberships_form_path" do
    it "returns the path for team membership" do
      create(:user, :confirmed)
      reserve = create(:reserve)
      project = create(:project, reserve: reserve)
      membership = create(:project_team_membership, project: project)
      form = ProjectTeamMembershipForm.new(params: { id: membership.id })
      presenter = Manager::Projects::TeamMembershipEditPresenter.new(form: form, reserve: reserve)

      expected_value = "/manager/reserves/#{reserve.id}/team_memberships/#{membership.id}"
      expect(presenter.team_memberships_form_path).to eq expected_value
    end
  end
end
