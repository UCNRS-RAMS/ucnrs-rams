require "rails_helper"

RSpec.describe Projects::TeamMembershipsIndexPresenter do
  describe "delegations" do
    subject { Projects::TeamMembershipsIndexPresenter.new(current_step: 1) }
    it { is_expected.to delegate_method(:svg).to(:steps_presenter) }
    it { is_expected.to delegate_method(:step_class).to(:steps_presenter) }
  end

  describe "#team_memberships" do
    it "creates a TeamMembershipPresenter for each team_membership" do
      project = create(:project)
      team_memberships = create_list(:project_team_membership, 3, project: project)
      presenter = Projects::TeamMembershipsIndexPresenter.new(current_step: 2, project: project)

      results = presenter.team_memberships

      expect(results.map(&:id)).to eq [
        team_memberships[0].id,
        team_memberships[1].id,
        team_memberships[2].id,
      ]
    end
  end

  describe "#project_roles" do
    it "is a list of project roles" do
      presenter = Projects::TeamMembershipsIndexPresenter.new(
        current_step: 2,
        project: create(:project),
      )

      expect(presenter.project_roles).to eq [
        "PI - Principal Investigator",
        "Project Manager",
        "Team Member",
        "Billing",
      ]
    end
  end
end
