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
    it "display a formatted project start and end date" do
      project = create(:project, start_date: Date.today, end_date: Date.tomorrow)
      presenter = Mail::User::ProjectPresenter.new(project)

      timeframe = presenter.timeframe

      expect(presenter.timeframe)
        .to eq DateRangePresenter.value(start_date: Date.today, end_date: Date.tomorrow)
    end
  end
end
