require "rails_helper"

RSpec.describe ProjectShowPresenter do
  describe "#created_at" do
    it "display a formatted creation datetime of the project with default format" do
      travel_to Time.zone.local(2004, 11, 24)
      project = create(:project, created_at: Time.current)
      presenter = Manager::ProjectShowPresenter.new(project)

      expect(presenter.created_at).to eq "Nov. 24, 2004"
    end

    it "display a formatted creation datetime of the project with specified format" do
      travel_to Time.zone.local(2004, 11, 24, 1, 4, 44)
      project = create(:project, created_at: Time.current)
      presenter = Manager::ProjectShowPresenter.new(project)

      expect(presenter.created_at(format: :project_summary_time)).to eq "Nov. 24, 2004 at  1:04 AM"
    end
  end

  describe "#updated_at" do
    it "display a formatted updation datetime of the project with default format" do
      travel_to Time.zone.local(2004, 11, 24)
      project = create(:project, updated_at: Time.current)
      presenter = Manager::ProjectShowPresenter.new(project)

      expect(presenter.updated_at).to eq "Nov. 24, 2004"
    end

    it "display a formatted updation datetime of the project with specified format" do
      travel_to Time.zone.local(2004, 11, 24, 1, 4, 44)
      project = create(:project, updated_at: Time.current)
      presenter = Manager::ProjectShowPresenter.new(project)

      expect(presenter.updated_at(format: :project_summary_time)).to eq "Nov. 24, 2004 at  1:04 AM"
    end
  end

  describe "#owner_name" do
    it "display the full name of the project owner" do
      user1 = create(:user, first_name: "user", last_name: "one")
      project = create(:project, owner: user1)
      presenter = Manager::ProjectShowPresenter.new(project)

      expect(presenter.owner_name).to eq "user one"
    end
  end

  describe "#project_type" do
    it "display the type of the project" do
      project = create(:project, project_type: "public_use")
      presenter = Manager::ProjectShowPresenter.new(project)

      expect(presenter.project_type).to eq "Public Use"
    end
  end

  describe "#reserve_names" do
    it "display the reserves name of visits for project" do
      project = create(:project)
      reserve1 = create(:reserve, name: "Test Reserve 1")
      reserve2 = create(:reserve, name: "Test Reserve 2")
      create(:visit, project: project, reserve: reserve1)
      create(:visit, project: project, reserve: reserve2)
      presenter = Manager::ProjectShowPresenter.new(project)

      expect(presenter.reserve_names).to eq "Test Reserve 1, Test Reserve 2"
    end
  end

  describe "#project_info" do
    let(:expected_info) { "Open Research Project Created: Nov. 24, 2004 at  1:04 AM" }

    it "returns the project info" do
      project = create(:project,
        project_type: :research,
        status: :open,
        created_at: Time.zone.local(2004, 11, 24, 1, 4, 44))
      presenter = Manager::ProjectShowPresenter.new(project)

      expect(presenter.project_info).to eq expected_info
    end
  end

  describe "#team_memberships" do
    it "sorts the TeamMembershipPresenter array on status and role" do
      project = create(:project)
      active_principal_investigator = create(:project_team_membership, :principal_investigator,
        project: project)
      active_project_manager = create(:project_team_membership, :project_manager, project: project)
      inactive_principal_investigator = create(:project_team_membership, :principal_investigator,
        project: project, active: false)
      active_principal_investigator1 = create(:project_team_membership, :principal_investigator,
        project: project)
      presenter = Manager::ProjectShowPresenter.new(project)

      results = presenter.team_memberships.map(&:id)

      expect(results).to eq [
        active_principal_investigator.id,
        active_principal_investigator1.id,
        active_project_manager.id,
        inactive_principal_investigator.id,
      ]
    end
  end
end
