require "rails_helper"

RSpec.describe Mail::User::ProjectPresenter do
  describe "delegations" do
    subject { Mail::User::ProjectPresenter.new(build(:project)) }
    it { is_expected.to delegate_missing_methods_to(:project) }
  end

  describe "#principal_investigators_list" do
    it "presents sentence string for email subject" do
      user1 = create(:user, first_name: "john", last_name: "doe")
      user2 = create(:user, first_name: "jane", last_name: "doe")
      project = create(:project)
      create(:project_team_membership,
        user: user1,
        project: project,
        is_principal_investigator: true,
      )
      create(:project_team_membership,
        user: user2,
        project: project,
        is_principal_investigator: true,
      )
      presenter = Mail::User::ProjectPresenter.new(project)

      principal_investigators_list = presenter.principal_investigators_list

      expect(principal_investigators_list).to eq "john doe and jane doe"
    end
  end

  describe "#project_involves" do
    it "display a formatted list of project involves" do
      project = create(:project,
        involves_mammals: true,
        involves_reptiles: true,
        involves_amphibians: true,
        involves_fish: true,
        involves_birds: false,
        involves_plants_fungi_soil: true,
      )
      presenter = Mail::User::ProjectPresenter.new(project)

      project_involves = presenter.project_involves

      expect(project_involves)
        .to eq "Mammals, Reptiles, Amphibians, Fish, Plants, Fungi, and Soil"
    end
  end

  describe "#timeframe" do
    context "when project have visitor(s) in any of its visits" do
      it "has a timeframe" do
        project = create(:project, start_date: Time.zone.today, end_date: Time.zone.tomorrow)
        visit1 = create(:visit, project: project)
        visit2 = create(:visit, project: project)
        user_visit1 = create(:user_visit, visit: visit1,
          arrives_at: Time.zone.yesterday, departs_at: Time.zone.today)
        user_visit2 = create(:user_visit, visit: visit2,
          arrives_at: Time.zone.today, departs_at: Time.zone.tomorrow)
        presenter = Mail::User::ProjectPresenter.new(project)
        allow(DateRangePresenter).to receive(:value)

        presenter.timeframe

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
end
