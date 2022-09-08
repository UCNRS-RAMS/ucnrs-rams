require "rails_helper"

RSpec.describe Manager::Dashboard::CalendarVisitPresenter do
  let(:start_date) { Date.current.beginning_of_month.yesterday }
  let(:end_date) { Date.current.end_of_month.tomorrow }

  let!(:reserve) { create(:reserve) }
  let!(:visit) do
    create(:visit, reserve: reserve, start_date: start_date,
      end_date: end_date)
  end

  describe "#display_amenities_text?" do
    monday_date = Date.current.beginning_of_week(:monday)
    tuesday_date = Date.current.beginning_of_week(:tuesday)

    it "should return false when the date is not start date and day is not monday" do
      visit_presenter = Manager::Dashboard::CalendarVisitPresenter.new(visit: visit,
        date: tuesday_date)

      expect(visit_presenter.display_amenities_text?).to eq(false)
    end

    it "should return true when the day is monday" do
      visit_presenter = Manager::Dashboard::CalendarVisitPresenter.new(visit: visit,
        date: monday_date)

      expect(visit_presenter.display_amenities_text?).to eq(true)
    end

    it "should return true when the date is start date" do
      visit_presenter = Manager::Dashboard::CalendarVisitPresenter.new(visit: visit,
        date: start_date)

      expect(visit_presenter.display_amenities_text?).to eq(true)
    end
  end

  describe "#visitor_counts_bg" do
    it 'should return "visitor-count left-radius"' do
      visit_presenter = Manager::Dashboard::CalendarVisitPresenter.new(visit: visit,
        date: start_date)

      expect(visit_presenter.visitor_counts_bg).to eq("visitor-count left-radius")
    end

    it 'should return "visitor-count right-radius"' do
      visit_presenter = Manager::Dashboard::CalendarVisitPresenter.new(visit: visit,
        date: end_date)

      expect(visit_presenter.visitor_counts_bg).to eq("visitor-count right-radius")
    end

    it 'should return "visitor-count"' do
      visit_presenter = Manager::Dashboard::CalendarVisitPresenter.new(visit: visit)

      expect(visit_presenter.visitor_counts_bg).to eq("visitor-count")
    end
  end

  describe "#amentities_counts_bg" do
    it 'should return "amenity-count left-radius"' do
      visit_presenter = Manager::Dashboard::CalendarVisitPresenter.new(visit: visit,
        date: start_date)

      expect(visit_presenter.amentities_counts_bg).to eq("amenity-count left-radius")
    end

    it 'should return "amenity-count right-radius"' do
      visit_presenter = Manager::Dashboard::CalendarVisitPresenter.new(visit: visit,
        date: end_date)

      expect(visit_presenter.amentities_counts_bg).to eq("amenity-count right-radius")
    end

    it 'should return "amenity-count"' do
      visit_presenter = Manager::Dashboard::CalendarVisitPresenter.new(visit: visit)

      expect(visit_presenter.amentities_counts_bg).to eq("amenity-count")
    end
  end

  describe "#display_visitors_text?" do
    let(:date) { start_date + 2.days }

    it "should return true when the day is monday" do
      monday_date = Date.current.beginning_of_week(:monday)
      calender_visit_presenter = Manager::Dashboard::CalendarVisitPresenter.new(
        visit: visit,
        date: monday_date,
      )

      expect(calender_visit_presenter.display_visitors_text?([])).to eq true
    end

    it "should return true when the date is start date" do
      calender_visit_presenter = Manager::Dashboard::CalendarVisitPresenter.new(
        visit: visit,
        date: visit.starts_at.to_date,
      )

      expect(calender_visit_presenter.display_visitors_text?([])).to eq true
    end

    context "when the day is not monday and the visit start is differnt then the presenter date" do
      it "should return true when passed visits visitors count is different for visitors count of the visit on the date" do
        create(:user_visit, visit: visit, arrives_at: visit.starts_at, departs_at: visit.ends_at,
          count: 10)
        create(:user_visit, visit: visit, arrives_at: visit.starts_at.tomorrow,
          departs_at: visit.ends_at, count: 11)
        calender_visit_presenter1 = Manager::Dashboard::CalendarVisitPresenter.new(
          visit: visit,
          date: start_date,
        )
        calender_visit_presenter2 = Manager::Dashboard::CalendarVisitPresenter.new(
          visit: visit,
          date: start_date.tomorrow,
        )
        expect(calender_visit_presenter2.display_visitors_text?([calender_visit_presenter1])).to eq true
      end

      it "should return false when passed visits visitors count is same as the visitors count of the visit on the date" do
        create(:user_visit, visit: visit, arrives_at: visit.starts_at, departs_at: visit.ends_at,
          count: 10)
        calender_visit_presenter1 = Manager::Dashboard::CalendarVisitPresenter.new(
          visit: visit,
          date: start_date,
        )
        calender_visit_presenter2 = Manager::Dashboard::CalendarVisitPresenter.new(
          visit: visit,
          date: start_date.tomorrow,
        )
        expect(calender_visit_presenter2.display_visitors_text?([calender_visit_presenter1])).to eq false
      end
    end
  end
end
