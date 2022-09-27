require "rails_helper"

RSpec.describe Manager::VisitShowPresenter do
  describe "delegations" do
    subject { Manager::VisitShowPresenter.new(visit: create(:visit), current_user: create(:user, :confirmed)) }
    it { is_expected.to delegate_missing_methods_to(:visit) }
  end

  describe "#visit_date_range" do
    it "return visit overall date range" do
      visit = create(:visit, start_date: "20 sep 2022", end_date: "22 sep 2022")
      user = create(:user, :confirmed)
      show_presenter = Manager::VisitShowPresenter.new(visit: visit, current_user: user)

      expect(show_presenter.visit_date_range).to eq "Sep 20, 2022 - Sep 22, 2022"
    end
  end

  describe "#staff_member?" do
    it "return true if current user is a staff member of reserve" do
      user = create(:user, :confirmed)
      reserve = create(:reserve)
      visit = create(:visit, user: user, reserve: reserve)
      create(:reserve_personnel, user: user, reserve: reserve)
      show_presenter = Manager::VisitShowPresenter.new(visit: visit, current_user: user)

      expect(show_presenter.staff_member?).to eq true
    end
    
    it "return false if current user is not a staff member of reserve" do
      user = create(:user, :confirmed)
      reserve = create(:reserve)
      visit = create(:visit, user: user, reserve: reserve)
      show_presenter = Manager::VisitShowPresenter.new(visit: visit, current_user: user)

      expect(show_presenter.staff_member?).to eq false
    end
  end

  describe "#tab_params" do
    let(:show_presenter) { Manager::VisitShowPresenter.new(visit: create(:visit), current_user: create(:user, :confirmed)) }

    it "return default hash when arguments not given" do
      expected_output = {id: "summary", name: "Summary", path: "#", classes: "nav-link ", action_method: "changeTab"}

      expect(show_presenter.tab_params).to eq(expected_output)
    end

    it "return hash with given values" do
      expected_output = {id: "summary", name: show_presenter.status, path: "/visits", classes: "nav-link #{show_presenter.status_classes}", action_method: "changeTab"}

      expect(show_presenter.tab_params(id: "summary", name: show_presenter.status, path: "/visits", classes: show_presenter.status_classes, action_method: "changeTab")).to eq(expected_output)
    end

    it "return hash having same values for id and name when name is not given" do
      expected_output = {id: "summary", name: "Summary", path: "#", classes: "nav-link ", action_method: "changeTab"}

      expect(show_presenter.tab_params(id: "summary")).to eq(expected_output)
    end
  end

  describe "#status_classes" do
    it "display status text color based on status value" do
      user = create(:user, :confirmed)
      pending_visit = create(:visit, status: "in_review")
      approved_visit = create(:visit, status: "approved")
      cancelled_visit = create(:visit, status: "cancelled")
      denied_visit = create(:visit, status: "denied")

      pending_show_presenter = Manager::VisitShowPresenter.new(visit: pending_visit, current_user: user)
      approved_show_presenter = Manager::VisitShowPresenter.new(visit: approved_visit, current_user: user)
      cancelled_show_presenter = Manager::VisitShowPresenter.new(visit: cancelled_visit, current_user: user)
      denied_show_presenter = Manager::VisitShowPresenter.new(visit: denied_visit, current_user: user)

      expect(pending_show_presenter.status_classes).to eq "btn-status bg-in_review"
      expect(approved_show_presenter.status_classes).to eq "btn-status bg-approved"
      expect(cancelled_show_presenter.status_classes).to eq "btn-status bg-cancelled"
      expect(denied_show_presenter.status_classes).to eq "btn-status bg-denied"
    end
  end
end
