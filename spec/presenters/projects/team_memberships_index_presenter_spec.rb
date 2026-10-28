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

      expect(results.map(&:class).uniq).to eq [Projects::TeamMembershipPresenter]
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

  describe "#team_memberships_form_path" do
    it "returns the path for team membership" do
      project = create(:project)
      presenter = Projects::TeamMembershipsIndexPresenter.new(
        current_step: 2,
        project: project,
      )

      expected_value = "/projects/#{project.id}/team_memberships"
      expect(presenter.team_memberships_form_path).to eq expected_value
    end
  end

  describe "#user_form_path" do
    it "returns the path for user" do
      project = create(:project)
      presenter = Projects::TeamMembershipsIndexPresenter.new(
        current_step: 2,
        project: project,
      )
      expected_value = "/projects/#{project.id}/users/new"
      expect(presenter.user_form_path).to eq expected_value
    end
  end

  describe "#able_to_add_user?" do
    it "is true if the current user can add users to the project" do
      project = create(:project)
      membership = create(:project_team_membership, :team_member, project: project, can_add_project_user: true)
      presenter = Projects::TeamMembershipsIndexPresenter.new(
        current_step: 2,
        project: project,
        current_user: membership.user,
      )

      expect(presenter.able_to_add_user?).to eq true
    end

    it "is false if the current user cannot add users to the project" do
      project = create(:project)
      membership = create(:project_team_membership, :team_member, project: project, can_add_project_user: false)
      presenter = Projects::TeamMembershipsIndexPresenter.new(
        current_step: 2,
        project: project,
        current_user: membership.user,
      )

      expect(presenter.able_to_add_user?).to eq false
    end

    it "is nil if there is no current user" do
      presenter = Projects::TeamMembershipsIndexPresenter.new(
        current_step: 2,
        project: create(:project),
      )

      expect(presenter.able_to_add_user?).to be_nil
    end
  end

  describe "#continue_button" do
    it "continues to the permit questions when the user can edit the project" do
      project = create(:project)
      membership = create(:project_team_membership, :team_member, project: project, can_edit_project: true)
      presenter = Projects::TeamMembershipsIndexPresenter.new(
        current_step: 2,
        project: project,
        current_user: membership.user,
      )

      expect(presenter.continue_button[:partial])
        .to eq "shared/projects/team_memberships/next_step_button"
      expect(presenter.continue_button[:locals][:project_link])
        .to eq "/projects/#{project.id}/questions"
    end

    it "finishes on the project summary when the user cannot edit the project" do
      project = create(:project)
      membership = create(:project_team_membership, :team_member, project: project, can_edit_project: false)
      presenter = Projects::TeamMembershipsIndexPresenter.new(
        current_step: 2,
        project: project,
        current_user: membership.user,
      )

      expect(presenter.continue_button[:partial])
        .to eq "shared/projects/team_memberships/finish_button"
      expect(presenter.continue_button[:locals][:project_link]).to eq "/projects/#{project.id}"
    end
  end
end
