require "rails_helper"

RSpec.describe Manager::VisitShowPresenter do
  describe "delegations" do
    subject { Manager::VisitShowPresenter.new(visit: create(:visit), current_user: create(:user, :confirmed)) }
    it { is_expected.to delegate_missing_methods_to(:visit) }
  end

  describe "#visit_date_range" do
    it "return visit overall date range" do
      visit = create(:visit, starts_at: "20 sep 2022", ends_at: "22 sep 2022")
      user = create(:user, :confirmed)
      show_presenter = Manager::VisitShowPresenter.new(visit: visit, current_user: user)

      expect(show_presenter.visit_date_range).to eq "Sep 20, 2022 - Sep 22, 2022"
    end
  end

  describe "#tab_content_path" do
    it "return 'edit_manager_reserve_visit_detail_path' if selected_tab is details" do
      user = create(:user, :confirmed)
      reserve = create(:reserve)
      visit = create(:visit, user: user, reserve: reserve)

      show_presenter = Manager::VisitShowPresenter.new(visit: visit, current_user: user, selected_tab: "details")

      output = "/manager/reserves/#{reserve.id}/visits/#{visit.id}/detail/edit"

      expect(show_presenter.tab_content_path).to eq output
    end

    it "return 'manager_reserve_visit_user_visits_path' if selected_tab is visitors" do
      user = create(:user, :confirmed)
      reserve = create(:reserve)
      visit = create(:visit, user: user, reserve: reserve)

      show_presenter = Manager::VisitShowPresenter.new(visit: visit, current_user: user, selected_tab: "visitors")

      output = "/manager/reserves/#{reserve.id}/visits/#{visit.id}/user_visits"

      expect(show_presenter.tab_content_path).to eq output
    end

    it "return 'manager_reserve_visit_reserve_info_index_path' if selected_tab is reserve_info" do
      user = create(:user, :confirmed)
      reserve = create(:reserve)
      visit = create(:visit, user: user, reserve: reserve)

      show_presenter = Manager::VisitShowPresenter.new(visit: visit, current_user: user, selected_tab: "reserve_info")

      output = "/manager/reserves/#{reserve.id}/visits/#{visit.id}/reserve_info"

      expect(show_presenter.tab_content_path).to eq output
    end

    it "return manager_reserve_visit_invoices_path if selected_tab is invoices" do
      user = create(:user, :confirmed)
      reserve = create(:reserve)
      visit = create(:visit, user: user, reserve: reserve)

      show_presenter = Manager::VisitShowPresenter.new(visit: visit, current_user: user, selected_tab: "invoices")

      output = "/manager/reserves/#{reserve.id}/visits/#{visit.id}/invoices"

      expect(show_presenter.tab_content_path).to eq output
    end

    it "return manager_reserve_visit_summary_path if selected_tab is not present" do
      user = create(:user, :confirmed)
      reserve = create(:reserve)
      visit = create(:visit, user: user, reserve: reserve)

      show_presenter = Manager::VisitShowPresenter.new(visit: visit, current_user: user)

      output = "/manager/reserves/#{reserve.id}/visits/#{visit.id}/summary"

      expect(show_presenter.tab_content_path).to eq output
    end
  end

  describe "#tab_class" do
    it "return 'active' if tab is equals to selected_tab" do
      user = create(:user, :confirmed)
      visit = create(:visit, user: user)

      show_presenter = Manager::VisitShowPresenter.new(visit: visit, current_user: user, selected_tab: "invoices")

      expect(show_presenter.tab_class("invoices")).to eq "active"
    end

    it "return empty string if tab is equals to selected_tab" do
      user = create(:user, :confirmed)
      visit = create(:visit, user: user)

      show_presenter = Manager::VisitShowPresenter.new(visit: visit, current_user: user, selected_tab: "invoices")

      expect(show_presenter.tab_class("summary")).to eq ""
    end
  end

  describe "#reserve_manager?" do
    it "return true if current user is a staff member of reserve" do
      user = create(:user, :confirmed)
      reserve = create(:reserve)
      visit = create(:visit, user: user, reserve: reserve)
      create(:reserve_personnel, user: user, reserve: reserve)
      show_presenter = Manager::VisitShowPresenter.new(visit: visit, current_user: user)

      expect(show_presenter.reserve_manager?).to eq true
    end
    
    it "return false if current user is not a staff member of reserve" do
      user = create(:user, :confirmed)
      reserve = create(:reserve)
      visit = create(:visit, user: user, reserve: reserve)
      show_presenter = Manager::VisitShowPresenter.new(visit: visit, current_user: user)

      expect(show_presenter.reserve_manager?).to eq false
    end
  end

  describe "#tab_params" do
    let(:show_presenter) { Manager::VisitShowPresenter.new(visit: create(:visit), current_user: create(:user, :confirmed)) }

    it "return default hash when arguments not given" do
      expected_output = {id: "summary", name: "Summary", path: "#", classes: "nav-link ", action_method: "changeTab", clickable: true}

      expect(show_presenter.tab_params).to eq(expected_output)
    end

    it "return hash with given values" do
      expected_output = {id: "summary", name: show_presenter.status, path: "/visits", classes: "nav-link #{show_presenter.status_classes}", action_method: "changeTab", clickable: true }

      expect(show_presenter.tab_params(id: "summary", name: show_presenter.status, path: "/visits", classes: show_presenter.status_classes, action_method: "changeTab")).to eq(expected_output)
    end

    it "return hash having same values for id and name when name is not given" do
      expected_output = {id: "summary", name: "Summary", path: "#", classes: "nav-link ", action_method: "changeTab", clickable: true}

      expect(show_presenter.tab_params(id: "summary")).to eq(expected_output)
    end
  end

  describe "#btn_class" do
    it "return 'disabled-link' if not staff_member" do
      user = create(:user, :confirmed)
      reserve = create(:reserve)
      visit = create(:visit, user: user, reserve: reserve)
      show_presenter = Manager::VisitShowPresenter.new(visit: visit, current_user: user)

      expected_output = "disabled-link"

      expect(show_presenter.btn_class).to eq(expected_output)
    end

    it "return 'disabled-link' if not staff_member" do
      user = create(:user, :confirmed)
      reserve = create(:reserve)
      visit = create(:visit, user: user, reserve: reserve)
      create(:reserve_personnel, user: user, reserve: reserve)
      show_presenter = Manager::VisitShowPresenter.new(visit: visit, current_user: user)

      expected_output = nil

      expect(show_presenter.btn_class).to eq(expected_output)
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
