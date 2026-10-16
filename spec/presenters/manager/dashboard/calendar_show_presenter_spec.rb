require "rails_helper"

RSpec.describe Manager::Dashboard::CalendarShowPresenter do
  def presenter_for(month:, year:, reserve: nil)
    described_class.new(
      reserve: reserve,
      filter: ReserveCalendarFilter.from_params({ month: month.to_s, year: year.to_s }),
    )
  end

  let(:reserve) { create(:reserve) }
  let(:presenter) { presenter_for(month: 5, year: 2026, reserve: reserve) }

  def approved_visit(from:, to:)
    user = create(:user, :confirmed)
    visit = create(:visit, reserve: reserve, status: :approved,
      starts_at: from.in_time_zone, ends_at: to.in_time_zone.end_of_day)
    create(:user_visit, visit: visit, user: user, status: :approved,
      arrives_at: from.in_time_zone, departs_at: to.in_time_zone.end_of_day)
    visit
  end

  describe "#date_range" do
    it "runs from the Sunday on/before the 1st to the Saturday on/after the last day" do
      range = presenter_for(month: 5, year: 2026).date_range

      expect(range.first).to eq Date.new(2026, 4, 26)
      expect(range.last).to eq Date.new(2026, 6, 6)
    end

    it "covers a whole number of weeks" do
      (1..12).each do |month|
        range = presenter_for(month: month, year: 2026).date_range

        expect(range.count % 7).to eq(0), "month #{month} spans #{range.count} days"
      end
    end

    it "is exactly the month when it starts on Sunday and ends on Saturday" do
      range = presenter_for(month: 2, year: 2026).date_range

      expect(range.first).to eq Date.new(2026, 2, 1)
      expect(range.last).to eq Date.new(2026, 2, 28)
    end
  end

  describe "#weeks" do
    it "returns whole Sunday to Saturday weeks covering the month" do
      weeks = presenter_for(month: 5, year: 2026).weeks

      expect(weeks.size).to eq 6
      expect(weeks.first.dates.first).to eq Date.new(2026, 4, 26)
      expect(weeks.last.dates.last).to eq Date.new(2026, 6, 6)
      expect(weeks).to all(have_attributes(dates: have_attributes(size: 7)))
    end

    it "returns exactly the month when it starts on Sunday and ends on Saturday" do
      weeks = presenter_for(month: 2, year: 2026).weeks

      expect(weeks.size).to eq 4
      expect(weeks.first.dates.first).to eq Date.new(2026, 2, 1)
      expect(weeks.last.dates.last).to eq Date.new(2026, 2, 28)
    end

    it "pads only the trailing partial week when the month starts on Sunday" do
      weeks = presenter_for(month: 3, year: 2026).weeks

      expect(weeks.size).to eq 5
      expect(weeks.first.dates.first).to eq Date.new(2026, 3, 1)
      expect(weeks.last.dates.last).to eq Date.new(2026, 4, 4)
    end

    it "starts every week on a Sunday" do
      weeks = presenter_for(month: 5, year: 2026).weeks

      expect(weeks.map { |week| week.dates.first.wday }).to all(eq 0)
    end

    it "holds no bars when there is no reserve in scope" do
      weeks = presenter_for(month: 2, year: 2026).weeks

      expect(weeks.map(&:entry_count)).to eq [ 0, 0, 0, 0 ]
    end

    it "lays the reserve's entries out on the month the filter selected" do
      approved_visit(from: Date.new(2026, 5, 4), to: Date.new(2026, 5, 6))

      weeks = presenter.weeks

      expect(weeks.size).to eq 6
      expect(weeks.sum(&:entry_count)).to be_positive
    end

    it "puts a bar spanning a week boundary on both weeks" do
      approved_visit(from: Date.new(2026, 5, 8), to: Date.new(2026, 5, 12))

      weeks = presenter.weeks.select { |week| week.entry_count.positive? }

      expect(weeks.size).to eq 2
    end
  end

  describe "#group_label" do
    it "returns the reserve's label for the group" do
      reserve.update!(amenity_group_label_2: "Housing")

      expect(presenter.group_label(2)).to eq "Housing"
    end

    it "falls back to the group number when the label is blank" do
      reserve.update!(amenity_group_label_3: "")

      expect(presenter.group_label(3)).to eq "3"
    end
  end

  describe "#short_group_label" do
    it "cuts a long label down to the pill length" do
      reserve.update!(amenity_group_label_1: "Field Station Housing and Dormitories")

      expect(presenter.short_group_label(1)).to eq "Field Statio..."
    end

    it "leaves a label that already fits alone" do
      reserve.update!(amenity_group_label_1: "Housing")

      expect(presenter.short_group_label(1)).to eq "Housing"
    end
  end

  describe "#entries" do
    it "points every bar at this calendar's visit modal" do
      visit = approved_visit(from: Date.new(2026, 5, 4), to: Date.new(2026, 5, 6))

      hrefs = presenter.entries.map(&:href)

      expect(hrefs).to all(
        start_with("/manager/reserves/#{reserve.id}/dashboard/calendar/visits/#{visit.id}")
      )
      expect(hrefs).to all(include("kind="))
    end
  end

  it "builds one schedule however many times the view asks it for data" do
    allow(Calendar::ReserveSchedule).to receive(:new).and_call_original

    presenter.entries
    presenter.visitor_counts
    presenter.weeks

    expect(Calendar::ReserveSchedule).to have_received(:new).once
  end

  it "bounds the schedule with the same span it draws the grid from" do
    allow(Calendar::ReserveSchedule).to receive(:new).and_call_original

    presenter.entries

    expect(Calendar::ReserveSchedule).to have_received(:new).with(
      hash_including(date_range: Date.new(2026, 4, 26)..Date.new(2026, 6, 6))
    )
  end
end
