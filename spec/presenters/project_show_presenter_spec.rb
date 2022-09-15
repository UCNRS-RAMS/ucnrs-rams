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

      expect(presenter.partial_name).to eq "shared/projects/research_show"
    end
  end

  describe "#timeframe" do
    it "display a formatted project start and end date" do
      project = create(:project, start_date: Date.today, end_date: Date.tomorrow)
      presenter = ProjectShowPresenter.new(project)

      expect(presenter.timeframe).to eq DateRangePresenter.value(start_date: Date.today, end_date: Date.tomorrow)
    end
  end

  describe "#team_memberships" do
    it "creates a TeamMembershipPresenter for each team_membership" do
      project = create(:project)
      team_memberships = create_list(:project_team_membership, 3, project: project)
      presenter = ProjectShowPresenter.new(project)

      results = presenter.team_memberships

      expect(results.map(&:id)).to eq [
        team_memberships[0].id,
        team_memberships[1].id,
        team_memberships[2].id,
      ]
    end
  end

  describe "#display_approved_permits?" do
    it "return true when approved_permit is present" do
      project = create(:project, approved_permits: "lorem ipsum")
      presenter = ProjectShowPresenter.new(project)

      expect(presenter.display_approved_permits?).to eq true
    end

    it "return false when approved_permit is not present" do
      project = create(:project, approved_permits: "")
      presenter = ProjectShowPresenter.new(project)

      expect(presenter.display_approved_permits?).to eq false
    end
  end

  describe "#fundings" do
    it "creates a FundingPresenter for each funding" do
      project = create(:project)
      fundings = create_list(:funding, 3, project: project)
      presenter = ProjectShowPresenter.new(project)

      results = presenter.fundings

      expect(results.map(&:id)).to eq [
        fundings[0].id,
        fundings[1].id,
        fundings[2].id,
      ]
    end
  end

  describe "#permit_answers" do
    it "creates a ProjectPermitAnswerPresenter for each project_permit_answer" do
      project = create(:project)
      project_permit_answers = create_list(:project_permit_answer, 3, project: project, answer: true)
      presenter = ProjectShowPresenter.new(project)

      results = presenter.permit_answers

      expect(results.values.flatten.map(&:id)).to eq [
        project_permit_answers[0].id,
        project_permit_answers[1].id,
        project_permit_answers[2].id,
      ]
    end
  end

  describe "#reserve_answers" do
    it "creates a ProjectReserveAnswerPresenter for each project_reserve_answer" do
      project = create(:project)
      project_reserve_answers = create_list(:project_reserve_answer, 3, project: project, boolean_answer: true)
      presenter = ProjectShowPresenter.new(project)

      results = presenter.reserve_answers

      expect(results.values.flatten.map(&:id)).to eq [
        project_reserve_answers[0].id,
        project_reserve_answers[1].id,
        project_reserve_answers[2].id,
      ]
    end
  end
end
