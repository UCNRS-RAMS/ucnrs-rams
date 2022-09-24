require "rails_helper"

RSpec.describe Manager::DashboardShowPresenter do
  describe "delegations" do
    subject { Manager::DashboardShowPresenter.new(reserve: build(:reserve)) }
    it { is_expected.to delegate_method(:id).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:name).to(:reserve).with_prefix(true) }
  end

  describe "#reserve" do
    it "presents reserve informations correctly through the presenter" do
      reserve = create(:reserve, name: "reserve 1")

      presenter = Manager::DashboardShowPresenter.new(reserve: reserve)

      expect(presenter.reserve_name).to eq "reserve 1"
    end
  end

  describe "#visitors_today" do
    it "returns user_visits at given reserve" do
      reserve1 = create(:reserve)
      reserve2 = create(:reserve)
      visit1 = create(:visit, reserve: reserve1, starts_at: 3.week.ago, ends_at: 3.week.from_now)
      visit2 = create(:visit, reserve: reserve2, starts_at: 3.week.ago, ends_at: 3.week.from_now)
      visit3 = create(:visit, reserve: reserve1, starts_at: 3.week.ago, ends_at: 3.week.from_now)
      user_visit1 = create(:user_visit, visit: visit1, arrives_at: 1.week.ago, departs_at: 1.week.from_now)
      user_visit2 = create(:user_visit, visit: visit2, arrives_at: 1.week.ago, departs_at: 1.week.from_now)
      user_visit3 = create(:user_visit, visit: visit1, arrives_at: 1.week.ago, departs_at: 1.week.from_now)
      user_visit4 = create(:user_visit, visit: visit3, arrives_at: 1.week.ago, departs_at: 1.week.from_now)
      presenter = Manager::DashboardShowPresenter.new(reserve: reserve1)

      results = presenter.visitors_today

      expect(results.map(&:id)).to match_array [user_visit1.id, user_visit3.id, user_visit4.id]
    end

    it "returns user visits where today is between the arrives_at and departs_at dates" do
      reserve = create(:reserve)
      visit = create(:visit, reserve: reserve, starts_at: 3.week.ago, ends_at: 3.week.from_now)
      user_visit1 = create(:user_visit, visit: visit, arrives_at: 1.week.ago, departs_at: 1.week.from_now)
      user_visit2 = create(:user_visit, visit: visit, arrives_at: Time.current, departs_at: Time.current)
      user_visit3 = create(:user_visit, visit: visit, arrives_at: 1.week.ago, departs_at: Time.current)
      user_visit4 = create(:user_visit, visit: visit, arrives_at: Time.current, departs_at: 1.day.from_now)
      user_visit5 = create(:user_visit, visit: visit, arrives_at: 1.week.ago, departs_at: 1.day.ago)
      presenter = Manager::DashboardShowPresenter.new(reserve: reserve)

      results = presenter.visitors_today

      expect(results.map(&:id)).to match_array [user_visit1.id, user_visit2.id, user_visit3.id, user_visit4.id]
    end

    it "returns user visits ordered by earliest arrives_at first" do
      reserve = create(:reserve)
      visit = create(:visit, reserve: reserve, starts_at: 3.month.ago, ends_at: 3.month.from_now)
      user_visit1 = create(:user_visit, visit: visit, arrives_at: 1.week.ago, departs_at: 1.week.from_now)
      user_visit2 = create(:user_visit, visit: visit, arrives_at: Time.current, departs_at: Time.current)
      user_visit3 = create(:user_visit, visit: visit, arrives_at: 3.week.ago, departs_at: Time.current)
      user_visit4 = create(:user_visit, visit: visit, arrives_at: 2.week.ago, departs_at: 1.day.from_now)
      presenter = Manager::DashboardShowPresenter.new(reserve: reserve)

      results = presenter.visitors_today

      expect(results.map(&:id)).to eq [user_visit3.id, user_visit4.id, user_visit1.id, user_visit2.id]
    end

    it "returns user visits wrapped in UserVisitPresenter" do
      reserve = create(:reserve)
      visit = create(:visit, reserve: reserve, starts_at: 3.month.ago, ends_at: 3.month.from_now)
      user_visit1 = create(:user_visit, visit: visit, arrives_at: 1.week.ago, departs_at: 1.week.from_now)
      user_visit2 = create(:user_visit, visit: visit, arrives_at: Time.current, departs_at: Time.current)
      user_visit3 = create(:user_visit, visit: visit, arrives_at: 3.week.ago, departs_at: Time.current)
      presenter = Manager::DashboardShowPresenter.new(reserve: reserve)

      results = presenter.visitors_today

      expect(results).to all(be_a(UserVisitPresenter))
      expect(results.map(&:id)).to match_array [user_visit1.id, user_visit2.id, user_visit3.id]
    end
  end

  describe "#amenities_today" do
    it "returns amenity_visits at given reserve" do
      reserve1 = create(:reserve)
      reserve2 = create(:reserve)
      visit1 = create(:visit, reserve: reserve1, starts_at: 3.week.ago, ends_at: 3.week.from_now)
      visit2 = create(:visit, reserve: reserve2, starts_at: 3.week.ago, ends_at: 3.week.from_now)
      visit3 = create(:visit, reserve: reserve1, starts_at: 3.week.ago, ends_at: 3.week.from_now)
      amenity_visit1 = create(:amenity_visit, visit: visit1, arrives: 1.week.ago, departs: 1.week.from_now)
      amenity_visit2 = create(:amenity_visit, visit: visit2, arrives: 1.week.ago, departs: 1.week.from_now)
      amenity_visit3 = create(:amenity_visit, visit: visit1, arrives: 1.week.ago, departs: 1.week.from_now)
      amenity_visit4 = create(:amenity_visit, visit: visit3, arrives: 1.week.ago, departs: 1.week.from_now)
      presenter = Manager::DashboardShowPresenter.new(reserve: reserve1)

      results = presenter.amenities_today

      expect(results.map(&:id)).to match_array [amenity_visit1.id, amenity_visit3.id, amenity_visit4.id]
    end

    it "returns amenity_visits where today is between the arrives_at and departs_at dates" do
      reserve = create(:reserve)
      visit = create(:visit, reserve: reserve, starts_at: 3.week.ago, ends_at: 3.week.from_now)
      amenity_visit1 = create(:amenity_visit, visit: visit, arrives: 1.week.ago, departs: 1.week.from_now)
      amenity_visit2 = create(:amenity_visit, visit: visit, arrives: Time.current, departs: Time.current)
      amenity_visit3 = create(:amenity_visit, visit: visit, arrives: 1.week.ago, departs: Time.current)
      amenity_visit4 = create(:amenity_visit, visit: visit, arrives: Time.current, departs: 1.day.from_now)
      amenity_visit5 = create(:amenity_visit, visit: visit, arrives: 1.week.ago, departs: 1.day.ago)
      presenter = Manager::DashboardShowPresenter.new(reserve: reserve)

      results = presenter.amenities_today

      expect(results.map(&:id)).to match_array [amenity_visit1.id, amenity_visit2.id, amenity_visit3.id, amenity_visit4.id]
    end

    it "returns amenity_visits ordered by earliest arrives_at first" do
      reserve = create(:reserve)
      visit = create(:visit, reserve: reserve, starts_at: 3.month.ago, ends_at: 3.month.from_now)
      amenity_visit1 = create(:amenity_visit, visit: visit, arrives: 1.week.ago, departs: 1.week.from_now)
      amenity_visit2 = create(:amenity_visit, visit: visit, arrives: Time.current, departs: Time.current)
      amenity_visit3 = create(:amenity_visit, visit: visit, arrives: 3.week.ago, departs: Time.current)
      amenity_visit4 = create(:amenity_visit, visit: visit, arrives: 2.week.ago, departs: 1.day.from_now)
      presenter = Manager::DashboardShowPresenter.new(reserve: reserve)

      results = presenter.amenities_today

      expect(results.map(&:id)).to eq [amenity_visit3.id, amenity_visit4.id, amenity_visit1.id, amenity_visit2.id]
    end

    it "returns amenity_visits wrapped in AmenityVisitPresenter" do
      reserve = create(:reserve)
      visit = create(:visit, reserve: reserve, starts_at: 3.month.ago, ends_at: 3.month.from_now)
      amenity_visit1 = create(:amenity_visit, visit: visit, arrives: 1.week.ago, departs: 1.week.from_now)
      amenity_visit2 = create(:amenity_visit, visit: visit, arrives: Time.current, departs: Time.current)
      amenity_visit3 = create(:amenity_visit, visit: visit, arrives: 3.week.ago, departs: Time.current)
      presenter = Manager::DashboardShowPresenter.new(reserve: reserve)

      results = presenter.amenities_today

      expect(results).to all(be_a(AmenityVisitPresenter))
      expect(results.map(&:id)).to match_array [amenity_visit1.id, amenity_visit2.id, amenity_visit3.id]
    end
  end

  describe "#visit_day" do
    it "returns all the visits from #visitors_today and #amenities_today" do
      reserve = create(:reserve)
      visit1 = create(:visit, reserve: reserve)
      visit2 = create(:visit, reserve: reserve)
      visit3 = create(:visit, reserve: reserve)
      visitors_today = [
        build(:user_visit, visit: visit1),
        build(:user_visit, visit: visit2),
        build(:user_visit, visit: visit1),
      ]
      amenities_today = [
        build(:amenity_visit, visit: visit2),
        build(:amenity_visit, visit: visit1),
        build(:amenity_visit, visit: visit3),
      ]
      presenter = Manager::DashboardShowPresenter.new(reserve: reserve)
      allow(presenter).to receive(:visitors_today).and_return(visitors_today)
      allow(presenter).to receive(:amenities_today).and_return(amenities_today)

      results = presenter.visit_day

      expect(results.map(&:id)).to match_array [visit1.id, visit2.id, visit3.id]
    end
  end

  describe "#visit_day_list" do
    it "returns list of user_visits and amenity_visits group by visits" do
      reserve = create(:reserve)
      visit1 = create(:visit, reserve: reserve)
      visit2 = create(:visit, reserve: reserve)
      visit3 = create(:visit, reserve: reserve)
      user_visit1 = build(:user_visit, visit: visit1)
      user_visit2 = build(:user_visit, visit: visit2)
      user_visit3 = build(:user_visit, visit: visit1)
      amenity_visit1 = build(:amenity_visit, visit: visit2)
      amenity_visit2 = build(:amenity_visit, visit: visit1)
      amenity_visit3 = build(:amenity_visit, visit: visit3)
      visitors_today = [
        user_visit1,
        user_visit2,
        user_visit3,
      ]
      amenities_today = [
        amenity_visit1,
        amenity_visit2,
        amenity_visit3,
      ]
      presenter = Manager::DashboardShowPresenter.new(reserve: reserve)
      allow(presenter).to receive(:visitors_today).and_return(visitors_today)
      allow(presenter).to receive(:amenities_today).and_return(amenities_today)

      results = presenter.visit_day_list

      expect(results.keys.map(&:id)).to match_array [visit1.id, visit2.id, visit3.id]
      expect(results[visit1].map(&:id)).to eq [user_visit1.id, user_visit3.id, amenity_visit2.id]
      expect(results[visit2].map(&:id)).to eq [user_visit2.id, amenity_visit1.id]
      expect(results[visit3].map(&:id)).to eq [amenity_visit3.id]
    end
  end

  describe "#visit_week_perday" do
    it "returns the amount of visits submitted per date from 6 days ago to now at given reserve" do
      reserve = create(:reserve)
      create_list(:visit, 3, submitted_at: 6.day.ago, reserve: reserve)
      create(:visit, submitted_at: 6.day.ago, status: :in_review, reserve: reserve)
      create_list(:visit, 5, submitted_at: 5.day.ago, reserve: reserve)
      create_list(:visit, 6, submitted_at: 4.day.ago, reserve: reserve)
      create_list(:visit, 1, submitted_at: 3.day.ago, reserve: reserve)
      create_list(:visit, 2, submitted_at: 2.day.ago, reserve: reserve)
      create_list(:visit, 4, submitted_at: 1.day.ago, reserve: reserve)
      create_list(:visit, 1, submitted_at: 1.hour.ago, reserve: reserve)
      create(:visit, submitted_at: 1.hour.ago, status: :incomplete, reserve: reserve)
      presenter = Manager::DashboardShowPresenter.new(reserve: reserve)

      results = presenter.visit_week_perday

      expect(results.values.count).to eq 7
      expect(results.values).to eq [4, 5, 6, 1, 2, 4, 2]
    end
  end

  describe "#visit_booked_week_perday" do
    it "returns the amount of approved visits submitted per date from 6 days ago to now at given reserve" do
      reserve = create(:reserve)
      create_list(:visit, 3, submitted_at: 6.day.ago, status: :approved, reserve: reserve)
      create(:visit, submitted_at: 6.day.ago, status: :incomplete, reserve: reserve)
      create_list(:visit, 5, submitted_at: 5.day.ago, status: :approved, reserve: reserve)
      create_list(:visit, 6, submitted_at: 4.day.ago, status: :approved, reserve: reserve)
      create_list(:visit, 1, submitted_at: 3.day.ago, status: :approved, reserve: reserve)
      create_list(:visit, 2, submitted_at: 2.day.ago, status: :approved, reserve: reserve)
      create_list(:visit, 4, submitted_at: 1.day.ago, status: :approved, reserve: reserve)
      create_list(:visit, 1, submitted_at: 1.hour.ago, status: :approved, reserve: reserve)
      create(:visit, submitted_at: 1.hour.ago, status: :incomplete, reserve: reserve)
      presenter = Manager::DashboardShowPresenter.new(reserve: reserve)

      results = presenter.visit_booked_week_perday

      expect(results.values.count).to eq 7
      expect(results.values).to eq [3, 5, 6, 1, 2, 4, 1]
    end
  end

  describe "#chart_data" do
    it "returns data from #visit_week_perday and #visit_booked_week_perday in correct format for charting" do
      allow(I18n).to receive(:t)
        .with("manager.dashboards.show.visit_request")
        .and_return("visit_request_translate")
      allow(I18n).to receive(:t)
        .with("manager.dashboards.show.booked_visit")
        .and_return("booked_visit_translate")
      visit_week_perday = "visit week data".freeze
      visit_booked_week_perday = "booked visit week data".freeze
      presenter = Manager::DashboardShowPresenter.new
      allow(presenter).to receive(:visit_week_perday).and_return(visit_week_perday)
      allow(presenter).to receive(:visit_booked_week_perday).and_return(visit_booked_week_perday)

      results = presenter.chart_data

      expect(results).to eq [
        { name: "visit_request_translate", data: visit_week_perday },
        { name: "booked_visit_translate", data: visit_booked_week_perday },
      ]
    end
  end

  describe "#visit_request_day_count" do
    it "returns the number of visits submitted today" do
      reserve = create(:reserve)
      create_list(:visit, 3, submitted_at: Time.current, status: :approved, reserve: reserve)
      create_list(:visit, 2, submitted_at: 1.hour.ago, status: :in_review, reserve: reserve)
      presenter = Manager::DashboardShowPresenter.new(reserve: reserve)

      results = presenter.visit_request_day_count

      expect(results).to eq 5
    end
  end

  describe "#visit_request_day_count" do
    it "returns the number of visits submitted today for given reserve" do
      reserve = create(:reserve)
      create_list(:visit, 3, submitted_at: Time.current, status: :approved, reserve: reserve)
      create_list(:visit, 2, submitted_at: 1.hour.ago, status: :in_review, reserve: reserve)
      presenter = Manager::DashboardShowPresenter.new(reserve: reserve)

      results = presenter.visit_request_day_count

      expect(results).to eq 5
    end
  end

  describe "#visit_booked_day_count" do
    it "returns the number of approved visits submitted today for given reserve" do
      reserve = create(:reserve)
      create_list(:visit, 3, submitted_at: Time.current, status: :approved, reserve: reserve)
      create_list(:visit, 2, submitted_at: 1.hour.ago, status: :in_review, reserve: reserve)
      presenter = Manager::DashboardShowPresenter.new(reserve: reserve)

      results = presenter.visit_booked_day_count

      expect(results).to eq 3
    end
  end

  describe "#visit_request_week_count" do
    it "returns the number of visits submitted from the last 6 days for given reserve" do
      reserve = create(:reserve)
      create(:visit, submitted_at: 6.day.ago, status: :approved, reserve: reserve)
      create(:visit, submitted_at: 5.day.ago, status: :approved, reserve: reserve)
      create(:visit, submitted_at: 4.day.ago, status: :in_review, reserve: reserve)
      create(:visit, submitted_at: 3.day.ago, status: :approved, reserve: reserve)
      create(:visit, submitted_at: 2.day.ago, status: :in_review, reserve: reserve)
      create(:visit, submitted_at: 1.day.ago, status: :approved, reserve: reserve)
      create(:visit, submitted_at: 1.hour.ago, status: :in_review, reserve: reserve)
      presenter = Manager::DashboardShowPresenter.new(reserve: reserve)

      results = presenter.visit_request_week_count

      expect(results).to eq 7
    end
  end

  describe "#visit_booked_week_count" do
    it "returns the number of approved visits submitted from the last 6 days for given reserve" do
      reserve = create(:reserve)
      create(:visit, submitted_at: 6.day.ago, status: :approved, reserve: reserve)
      create(:visit, submitted_at: 5.day.ago, status: :approved, reserve: reserve)
      create(:visit, submitted_at: 4.day.ago, status: :in_review, reserve: reserve)
      create(:visit, submitted_at: 3.day.ago, status: :approved, reserve: reserve)
      create(:visit, submitted_at: 2.day.ago, status: :in_review, reserve: reserve)
      create(:visit, submitted_at: 1.day.ago, status: :approved, reserve: reserve)
      create(:visit, submitted_at: 1.hour.ago, status: :in_review, reserve: reserve)
      presenter = Manager::DashboardShowPresenter.new(reserve: reserve)

      results = presenter.visit_booked_week_count

      expect(results).to eq 4
    end
  end
end
