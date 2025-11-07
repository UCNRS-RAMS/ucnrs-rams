require "rails_helper"

RSpec.describe ProjectPresenter do
  describe "delegations" do
    subject { ProjectPresenter.new(project: create(:project)) }
    it { is_expected.to delegate_method(:id).to(:project) }
    it { is_expected.to delegate_method(:visits_count).to(:project) }
    it { is_expected.to delegate_method(:title).to(:project) }
    it { is_expected.to delegate_method(:applicant).to(:project) }
    it { is_expected.to delegate_method(:to_key).to(:project) }
    it { is_expected.to delegate_method(:model_name).to(:project) }
    it { is_expected.to delegate_missing_methods_to(:project) }
  end

  describe "#project_type" do
    it "capitalizes the first letter of the project type" do
      project_presenter = ProjectPresenter.new(
        project: create(:project, project_type: "research"),
      )

      expect(project_presenter.project_type).to eq "Research"
    end

    it "converts underscores in the project type to spaces and capitalizes the first letter of each word" do
      project_presenter = ProjectPresenter.new(
        project: create(:project, project_type: "public_use"),
      )

      expect(project_presenter.project_type).to eq "Public Use"
    end
  end

  describe "#timeframe" do
    context "when project have visitor(s) in any of its visits" do
      it "has a timeframe" do
        project = create(:project)
        visit1 = create(:visit, project: project)
        visit2 = create(:visit, project: project)
        user_visit1 = create(:user_visit, visit: visit1,
          arrives_at: Time.zone.yesterday, departs_at: Time.zone.today)
        user_visit2 = create(:user_visit, visit: visit2,
          arrives_at: Time.zone.today, departs_at: Time.zone.tomorrow)
        project_presenter = ProjectPresenter.new(project: project)
        allow(DateRangePresenter).to receive(:value)

        project_presenter.timeframe

        expect(DateRangePresenter).to have_received(:value)
          .with(start_date: user_visit1.arrives_at.to_date, end_date: user_visit2.departs_at.to_date)
      end
    end

    context "when project doesnt have visitors in any of its visits" do
      it "is 'N/A'" do
        project_presenter = ProjectPresenter.new(
          project: build(:project),
        )
        allow(DateRangePresenter).to receive(:value)

        result = project_presenter.timeframe

        expect(result).to eq "N/A"
        expect(DateRangePresenter).not_to have_received(:value)
      end
    end
  end

  describe "#recent_visit_date" do
    context "when the project has visits" do
      it "is the correctly formatted start_date of the most recent visit" do
        project = create(:project)
        create(:visit, project: project, starts_at: Time.zone.local(2019, 10, 1),
          submitted_at: Time.current)
        create(:visit, project: project, starts_at: Time.zone.local(2021, 10, 1),
          submitted_at: Time.current)
        project_presenter = ProjectPresenter.new(project: project)

        expect(project_presenter.recent_visit_date).to eq "Oct 01, 2021"
      end
    end

    context "when the project does not have visits" do
      it "is N/A" do
        project_presenter = ProjectPresenter.new(project: create(:project))

        expect(project_presenter.recent_visit_date).to eq "N/A"
      end
    end
  end

  describe "#recent_visit_reserve" do
    context "when the project has visits and the most recent visit has a reserve" do
      it "is is the reserve's short_name" do
        project = create(:project)
        reserve = create(:reserve, short_name: "Foo Reserve")
        create(:visit, project: project, reserve: reserve)
        project_presenter = ProjectPresenter.new(project: project)

        expect(project_presenter.recent_visit_reserve).to eq "Foo Reserve"
      end
    end

    context "when the project does not have visits" do
      it "is N/A" do
        project_presenter = ProjectPresenter.new(project: create(:project))

        expect(project_presenter.recent_visit_reserve).to eq "N/A"
      end
    end
  end

  describe "#applicant_name" do
    it "returns the project applicant full name" do
      user = create(:user, first_name: "Scrooge", last_name: "McDuck")
      project = create(:project, applicant: user)

      project_presenter = ProjectPresenter.new(project: project)

      expect(project_presenter.applicant_name).to eq "Scrooge McDuck"
    end
  end

  describe "#owner_name" do
    it "returns the project owner full name" do
      user = create(:user, first_name: "Scrooge", last_name: "McDuck")
      project = create(:project, owner: user)

      project_presenter = ProjectPresenter.new(project: project)

      expect(project_presenter.owner_name).to eq "Scrooge McDuck"
    end
  end

  describe "#principal_investigators" do
    it "returns array of project principal investigators names" do
      project = create(:project)
      user1 = create(:user, first_name: "Scrooge", last_name: "McDuck")
      create(:project_team_membership,
        project: project, user: user1, is_principal_investigator: false)
      user2 = create(:user, first_name: "Donald", last_name: "Duck")
      create(:project_team_membership,
        project: project, user: user2, is_principal_investigator: true)

      project_presenter = ProjectPresenter.new(project: project)

      expect(project_presenter.principal_investigators).to match_array [user2]
    end
  end

  describe "#other_team_members" do
    it "returns array of project non principal investigator team members users" do
      project = create(:project)
      user1 = create(:user, first_name: "Scrooge", last_name: "McDuck")
      create(:project_team_membership,
        project: project, user: user1, is_principal_investigator: false)
      user2 = create(:user, first_name: "Donald", last_name: "Duck")
      create(:project_team_membership,
        project: project, user: user2, is_principal_investigator: true)

      project_presenter = ProjectPresenter.new(project: project)

      expect(project_presenter.other_team_members).to match_array [user1]
    end
  end

  describe "#team_members_affiliations" do
    it "returns array of team members' institution names" do
      project  = create(:project)
      institution1 = create(:institution, name: "Two Trees University")
      membership1 = create(:project_team_membership,
        project: project, institution: institution1, is_principal_investigator: false,
      )
      institution2 = create(:institution, name: "Three Ducks University")
      membership2 = create(:project_team_membership,
        project: project, institution: institution2, is_principal_investigator: true,
      )

      project_presenter = ProjectPresenter.new(project: project)

      expect(project_presenter.team_members_affiliations)
        .to match_array ["Two Trees University", "Three Ducks University"]
    end
  end
end
