require "rails_helper"

RSpec.describe Mail::VisitNewPresenter do
  describe "delegations" do
    subject { Mail::VisitNewPresenter.new(build(:visit)) }
    it { is_expected.to delegate_missing_methods_to(:visit) }
  end

  describe "#visit_applicant_name" do
    it "presents the visit applicant full name" do
      user = create(:user, first_name: "john", last_name: "doe")
      visit = create(:visit, user: user)
      presenter = Mail::VisitNewPresenter.new(visit)

      visit_applicant_name = presenter.visit_applicant_name

      expect(visit_applicant_name).to eq "john doe"
    end
  end

  describe "#visit_applicant_email" do
    it "presents the visit applicant email" do
      user = create(:user, email: "email@me")
      visit = create(:visit, user: user)
      presenter = Mail::VisitNewPresenter.new(visit)

      visit_applicant_email = presenter.visit_applicant_email

      expect(visit_applicant_email).to eq "email@me"
    end
  end

  describe "#visit_reserve" do
    it "presents the visit reserve wrapped in ReservePresenter" do
      reserve = create(:reserve)
      visit = create(:visit, reserve: reserve)
      presenter = Mail::VisitNewPresenter.new(visit)

      visit_reserve = presenter.visit_reserve

      expect(visit_reserve).to be_a(ReservePresenter)
      expect(visit_reserve.id).to eq reserve.id
    end
  end

  describe "#visit_project" do
    it "presents the visit project wrapped in ProjectShowPresenter" do
      project = create(:project)
      visit = create(:visit, project: project)
      presenter = Mail::VisitNewPresenter.new(visit)

      visit_project = presenter.visit_project

      expect(visit_project).to be_a(ProjectShowPresenter)
      expect(visit_project.id).to eq project.id
    end
  end
end
