require "rails_helper"

RSpec.describe Manager::Dashboard::CalendarVisitShowPresenter do
  describe "#user_visits" do
    it "returns an array of Manager::Visits::UserVisitsPresenter for each user_visit" do
      visit = create(:visit)
      user_visits = create_list(:user_visit, 3, visit: visit)
      presenter = Manager::Dashboard::CalendarVisitShowPresenter.new(visit: visit)

      results = presenter.user_visits

      expect(results.map(&:id)).to eq [
        user_visits[0].id,
        user_visits[1].id,
        user_visits[2].id,
      ]
      expect(results).to all(be_instance_of Manager::Visits::UserVisitPresenter)
    end
  end

  describe "#user_info" do
    it "returns user full name in manager scope" do
      user = create(:user, first_name: "hafiz", last_name: "ahmad")
      visit = create(:visit, user: user)
      user_visits = create_list(:user_visit, 3, visit: visit)
      presenter = Manager::Dashboard::CalendarVisitShowPresenter.new(visit: visit)

      expect(presenter.user_info).to eq("hafiz ahmad")
    end
  end
end
