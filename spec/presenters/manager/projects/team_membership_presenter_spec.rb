require "rails_helper"

RSpec.describe Manager::Projects::TeamMembershipPresenter do
  describe "#edit_team_memberships_form_path" do
    it "returns the path for edit manager team membership" do
      team_membership = create(:project_team_membership)
      presenter = Manager::Projects::TeamMembershipPresenter.new(team_membership)

      expected_value = "/manager/team_memberships/#{team_membership.id}/edit"
      expect(presenter.edit_team_memberships_form_path).to eq expected_value
    end
  end
end
