require "rails_helper"

RSpec.describe ProjectShowPresenter do
  describe "#project_status" do
    it "display formatted project status" do
      project = create(:project)
      presenter = ProjectShowPresenter.new(project)

      expect(presenter.project_status).to eq "Open Application"
    end
  end

  describe "#submitted_at" do
    it "display a formatted submission datetime of the project" do
      travel_to Time.zone.local(2004, 11, 24, 1, 4, 44)
      project = create(:project, submitted_at: Time.current)
      presenter = ProjectShowPresenter.new(project)

      expect(presenter.submitted_at).to eq "Nov. 24, 2004 at  1:04 AM"
    end
  end

  describe "#principal_investigators_list" do
    it "display a formatted list of the principal investigators" do
      project = create(:project)
      user1 = create(:user, first_name: "user", last_name: "one")
      user2 = create(:user, first_name: "user", last_name: "two")
      user3 = create(:user, first_name: "user", last_name: "three")
      user4 = create(:user, first_name: "user", last_name: "four")
      create(:project_team_membership, user: user1, project: project, is_principal_investigator: true)
      create(:project_team_membership, user: user2, project: project, is_principal_investigator: true)
      create(:project_team_membership, user: user3, project: project, is_principal_investigator: true)
      create(:project_team_membership, user: user4, project: project)
      presenter = ProjectShowPresenter.new(project)

      expect(presenter.principal_investigators_list).to eq "user one, user two, and user three"
    end
  end

  describe "#applicant_name" do
    it "display the full name of the project applicant" do
      user1 = create(:user, first_name: "user", last_name: "one")
      project = create(:project, applicant: user1)
      presenter = ProjectShowPresenter.new(project)

      expect(presenter.applicant_name).to eq "user one"
    end
  end

  describe "#project_involves" do
    it "display a formatted list of project involves" do
      project = create(:project, involves_mammals: true, involves_reptiles: true, involves_amphibians: true,
                        involves_fish: true, involves_birds: false, involves_plants_fungi_soil: true)
      presenter = ProjectShowPresenter.new(project)

      expect(presenter.project_involves).to eq "Mammals, Reptiles, Amphibians, Fish, Plants, Fungi, and Soil"
    end
  end

  describe "#partial_name" do
    it "returns the partial path based on project type" do
      project = create(:project, project_type: :research)
      presenter = ProjectShowPresenter.new(project)

      expect(presenter.partial_name).to eq "projects/research_show"
    end
  end

  describe "#timeframe" do
    it "display a formatted project start and end date" do
      project = create(:project, start_date: Date.today, end_date: Date.tomorrow)
      presenter = ProjectShowPresenter.new(project)

      expect(presenter.timeframe).to eq DateRangePresenter.value(start_date: Date.today, end_date: Date.tomorrow)
    end
  end
end
