require "rails_helper"

RSpec.describe Manager::Projects::TeamMembershipsIndexPresenter do
  describe "#team_memberships" do
    it "creates a Manager::Projects::TeamMembershipPresenter for each team_membership" do
      reserve = create(:reserve)
      project = create(:project, reserve: reserve)
      team_memberships = create_list(:project_team_membership, 3, project: project)
      presenter = Manager::Projects::TeamMembershipsIndexPresenter.new(
        project: project,
        reserve: reserve,
      )

      results = presenter.team_memberships

      expect(results.map(&:id)).to eq [
        team_memberships[0].id,
        team_memberships[1].id,
        team_memberships[2].id,
      ]
      expect(results.map(&:class).uniq).to eq [Manager::Projects::TeamMembershipPresenter]
    end
  end

  describe "#team_memberships_form_path" do
    it "returns the path for manager reserve project team membership" do
      reserve = create(:reserve)
      project = create(:project, reserve: reserve)
      presenter = Manager::Projects::TeamMembershipsIndexPresenter.new(
        project: project,
        reserve: reserve,
      )

      expected_value = "/manager/reserves/#{reserve.id}/projects/#{project.id}/team_memberships"
      expect(presenter.team_memberships_form_path).to eq expected_value
    end
  end

  describe "#user_form_path" do
    it "returns the path for manager reserve project user" do
      reserve = create(:reserve)
      project = create(:project, reserve: reserve)
      presenter = Manager::Projects::TeamMembershipsIndexPresenter.new(
        project: project,
        reserve: reserve,
      )

      expected_value = "/manager/reserves/#{reserve.id}/projects/#{project.id}/users/new"
      expect(presenter.user_form_path).to eq expected_value
    end
  end
end
