require "rails_helper"

RSpec.describe Manager::UserShowPresenter do
  describe "delegations" do
    subject { Manager::UserShowPresenter.new(build(:user)) }
    it { is_expected.to delegate_missing_methods_to(:user) }
    it { is_expected.to delegate_method(:name).to(:institution).with_prefix(true) }
    it { is_expected.to delegate_method(:institution_type).to(:institution) }
  end

  describe "#user" do
    it "return user wrapped in UserPresenter" do
      user = create(:user, last_name: "McClane")
      show_presenter = Manager::UserShowPresenter.new(user)

      user = show_presenter.user

      expect(user).to be_a UserPresenter
      expect(user.last_name).to eq "McClane"
    end
  end

  describe "#institution" do
    it "return user institution wrapped in InstitutionPresenter" do
      user_institution = create(:institution, name: "Real University")
      user = create(:user, institution: user_institution)
      show_presenter = Manager::UserShowPresenter.new(user)

      institution = show_presenter.institution

      expect(institution).to be_a InstitutionPresenter
      expect(institution.name).to eq "Real University"
    end
  end

  describe "#number_of_project_members" do
    it "return the number of projects, the user is a member of" do
      user = create(:user)
      2.times { create(:project, team_memberships:[create(:project_team_membership, user: user)]) }
      create(:project, team_memberships:[create(:project_team_membership)])
      show_presenter = Manager::UserShowPresenter.new(user)

      number_of_project_members = show_presenter.number_of_project_members

      expect(number_of_project_members).to eq 2
    end
  end

  describe "#number_of_visits" do
    it "return number of visits, the user is on as a visitor" do
      user = create(:user)
      3.times { create(:visit, user_visits:[create(:user_visit, user: user)]) }
      create(:visit, user_visits:[create(:user_visit)])
      show_presenter = Manager::UserShowPresenter.new(user)

      number_of_visits = show_presenter.number_of_visits

      expect(number_of_visits).to eq 3
    end
  end
end
