require "rails_helper"

RSpec.describe Visits::UserVisitPresenter do
  describe "#visit_user_visit_form_path" do
    it "returns manager_reserve_visit_user_visit_path" do
      visit = create(:visit)
      user_visit = create(:user_visit, visit: visit)
      presenter = Manager::Visits::UserVisitPresenter.new(user_visit)

      expected_value = "/manager/reserves/#{visit.reserve_id}/visits/#{visit.id}/user_visits/#{user_visit.id}"
      expect(presenter.visit_user_visit_form_path).to eq expected_value
    end
  end

  describe "#edit_user_visit_form_path" do
    it "returns edit_user_visit_form_path" do
      visit = create(:visit)
      user_visit = create(:user_visit, visit: visit)
      presenter = Manager::Visits::UserVisitPresenter.new(user_visit)

      expected_value = "/manager/reserves/#{visit.reserve_id}/user_visits/#{user_visit.id}/edit"
      expect(presenter.edit_user_visit_form_path).to eq expected_value
    end
  end

  describe "#date_range" do
    it "return date range for with total number for days" do
      date = Date.current
      after_date = date + 2.days
      user_visit = create(:user_visit, arrives_at: date, departs_at: after_date)

      presenter = Manager::Visits::UserVisitPresenter.new(user_visit)

      expected_value = "#{date.strftime('%m/%d/%Y')} - #{after_date.strftime('%m/%d/%Y')} (3 days)"
      expect(presenter.date_range).to eq expected_value
    end
  end

  describe "#total_days" do
    it "returns total days of user visit" do
      date = Date.current
      user_visit = create(:user_visit, arrives_at: date, departs_at: date + 2.days)

      presenter = Manager::Visits::UserVisitPresenter.new(user_visit)

      expect(presenter.total_days).to eq 3
    end
  end
end
