require "rails_helper"

RSpec.describe AmenityVisit do
  describe "validations" do
    it { is_expected.to validate_date(:departs_on).is_after(:arrives_on) }
    it { is_expected.to validate_date(:departs).is_after(:arrives) }
    it { is_expected.to validate_numericality_of(:number_of_people).is_greater_than(0) }
  end

  describe "associations" do
    it {is_expected.to belong_to(:amenity) }
    it {is_expected.to belong_to(:amenity_rate) }
    it {is_expected.to belong_to(:user) }
    it {is_expected.to belong_to(:visit) }
    it { is_expected.to have_many(:logs) }
    it { should belong_to(:invoice).optional }
  end

  it do 
    is_expected.to define_enum_for(:status)
      .with_values(
        approved: "Approved",
        cancelled: "Cancelled",
        denied: "Rejected",
        in_review: "Pending approval",
      ).backed_by_column_of_type(:string)
  end

  describe "#amenity_visit_id=" do
    it "sets the `id`" do
      amenity_visit = AmenityVisit.new

      amenity_visit.amenity_visit_id = 2

      expect(amenity_visit.id).to eq 2
    end
  end

  describe "#calc_units_of_time" do
    it "calculate the units of time through num_of_units helper" do
      amenity_visit = create(:amenity_visit)
      allow(ApplicationController.helpers).to receive(:num_of_units)

      amenity_visit.calc_units_of_time

      expect(ApplicationController.helpers).to have_received(:num_of_units)
    end
  end

  describe "#real_units_of_time" do
    context "when manual_units_of_time is zero/blank" do
      it "returns calc_units_of_time" do
        amenity_visit = create(:amenity_visit, manual_units_of_time: 0)
        allow(ApplicationController.helpers).to receive(:num_of_units)

        amenity_visit.real_units_of_time

        expect(ApplicationController.helpers).to have_received(:num_of_units)
      end
    end

    context "when manual_units_of_time is not zero/blank" do
      it "returns manual_units_of_time" do
        amenity_visit = create(:amenity_visit, manual_units_of_time: 10)

        expect(amenity_visit.real_units_of_time).to eq 10
      end
    end
  end

  it do
    is_expected.to define_enum_for(:status)
      .with_values(
        approved: "Approved",
        in_review: "Pending approval",
        cancelled: "Cancelled",
        denied: "Rejected",
      ).backed_by_column_of_type(:string)
  end

  describe "#subtotal" do
    it "multiplies and return number_of_people * real_units_of_time * rate" do
      amenity_visit = create(:amenity_visit, number_of_people: 10, manual_units_of_time: 10, rate: 10)

      expect(amenity_visit.subtotal).to eq 1000
    end
  end

  describe ".at_reserve" do
    it "returns amenity visits from the given reserve" do
      reserve1 = create(:reserve)
      reserve2 = create(:reserve)
      visit1 = create(:visit, reserve: reserve1)
      visit2 = create(:visit, reserve: reserve2)
      amenity_visit1 = create(:amenity_visit, visit: visit1)
      amenity_visit2 = create(:amenity_visit, visit: visit2)
      amenity_visit3 = create(:amenity_visit, visit: visit1)

      results = AmenityVisit.at_reserve(reserve1)

      expect(results).to eq [amenity_visit1, amenity_visit3]
    end
  end

  describe ".earliest_arrives_date" do
    it "returns earliest arrives date between amenity visits" do
      visit = create(:visit, starts_at: 3.week.ago, ends_at: 3.week.from_now)
      amenity_visit1 = create(:amenity_visit, visit: visit, arrives: 1.week.ago, departs: 1.week.from_now)
      amenity_visit2 = create(:amenity_visit, visit: visit, arrives: Time.current, departs:Time.current)
      results = AmenityVisit.earliest_arrives_date

      expect(results).to eq amenity_visit1.arrives
    end
  end

  describe ".latest_departs_date" do
    it "returns latest departs date amenity visits" do
      visit = create(:visit, starts_at: 3.week.ago, ends_at: 3.week.from_now)
      amenity_visit1 = create(:amenity_visit, visit: visit, arrives: 1.week.ago, departs: 1.week.from_now)
      amenity_visit2 = create(:amenity_visit, visit: visit, arrives: Time.current, departs: 2.week.from_now)
      results = AmenityVisit.latest_departs_date

      expect(results).to eq amenity_visit2.departs
    end
  end

  describe ".can_invoice_now" do
    it "returns amenity visits where 'invoice_now' is true" do
      amenity_visit1 = create(:amenity_visit, invoice_now: true)
      amenity_visit2 = create(:amenity_visit, invoice_now: false)
      amenity_visit3 = create(:amenity_visit, invoice_now: true)

      results = AmenityVisit.can_invoice_now(false)

      expect(results).to eq [amenity_visit1, amenity_visit3]
    end
  end

  describe ".uninvoiced" do
    it "returns amenity visits which are not invoiced" do
      amenity_visit1 = create(:amenity_visit, invoice_id: create(:invoice).id)
      amenity_visit2 = create(:amenity_visit, invoice_id: nil)
      amenity_visit3 = create(:amenity_visit, invoice_id: create(:invoice).id)

      results = AmenityVisit.uninvoiced

      expect(results).to eq [amenity_visit2]
    end
  end

  describe ".having_between_time" do
    let(:visit) { create(:visit, starts_at: 6.weeks.ago, ends_at: 6.weeks.from_now) }
    let(:range_start) { Date.current }
    let(:range_end) { Date.current + 6.days }

    def amenity_visit_from(arrives, departs)
      create(:amenity_visit, visit: visit, arrives: arrives, departs: departs)
    end

    it "returns only the rows whose [arrives..departs] overlaps the range" do
      amenity_visit_from(range_start - 5.days, range_start - 2.days)
      overlaps_start = amenity_visit_from(range_start - 2.days, range_start + 1.day)
      inside = amenity_visit_from(range_start + 1.day, range_start + 2.days)
      overlaps_end = amenity_visit_from(range_end - 1.day, range_end + 3.days)
      spans_range = amenity_visit_from(range_start - 3.days, range_end + 3.days)
      amenity_visit_from(range_end + 2.days, range_end + 4.days)

      results = AmenityVisit.having_between_time(date_start: range_start, date_end: range_end)

      expect(results).to match_array [overlaps_start, inside, overlaps_end, spans_range]
    end

    it "includes a row departing on the first day of the range" do
      departs_on_first_day = amenity_visit_from(range_start - 2.days, range_start)

      results = AmenityVisit.having_between_time(date_start: range_start, date_end: range_end)

      expect(results).to include departs_on_first_day
    end

    it "includes a row arriving on the last day of the range" do
      arrives_on_last_day = amenity_visit_from(range_end, range_end + 2.days)

      results = AmenityVisit.having_between_time(date_start: range_start, date_end: range_end)

      expect(results).to include arrives_on_last_day
    end

    it "compares whole days, ignoring the time of day on the bounds" do
      departs_early_on_first_day =
        amenity_visit_from(range_start - 2.days, range_start.in_time_zone.change(hour: 2))

      results = AmenityVisit.having_between_time(
        date_start: range_start.in_time_zone.change(hour: 15),
        date_end: range_end,
      )

      expect(results).to include departs_early_on_first_day
    end

    context "when date_start is nil" do
      it "only applies the upper bound" do
        long_past = amenity_visit_from(range_start - 20.days, range_start - 15.days)
        inside = amenity_visit_from(range_start + 1.day, range_start + 2.days)
        amenity_visit_from(range_end + 2.days, range_end + 4.days)

        results = AmenityVisit.having_between_time(date_start: nil, date_end: range_end)

        expect(results).to match_array [long_past, inside]
      end
    end

    context "when date_end is nil" do
      it "only applies the lower bound" do
        amenity_visit_from(range_start - 5.days, range_start - 2.days)
        inside = amenity_visit_from(range_start + 1.day, range_start + 2.days)
        far_future = amenity_visit_from(range_end + 20.days, range_end + 25.days)

        results = AmenityVisit.having_between_time(date_start: range_start, date_end: nil)

        expect(results).to match_array [inside, far_future]
      end
    end

    context "when both bounds are nil" do
      it "returns every row" do
        before_range = amenity_visit_from(range_start - 5.days, range_start - 2.days)
        inside = amenity_visit_from(range_start + 1.day, range_start + 2.days)
        after_range = amenity_visit_from(range_end + 2.days, range_end + 4.days)

        results = AmenityVisit.having_between_time(date_start: nil, date_end: nil)

        expect(results).to match_array [before_range, inside, after_range]
      end
    end
  end

  describe ".on_date" do
    it "returns amenity visits with a given date on/or between the arrives_at and departs_at dates" do
      visit = create(:visit, starts_at: 3.week.ago, ends_at: 3.week.from_now)
      amenity_visit1 = create(:amenity_visit, visit: visit, arrives: 1.week.ago, departs: 1.week.from_now)
      amenity_visit2 = create(:amenity_visit, visit: visit, arrives: Time.current, departs:Time.current)
      amenity_visit3 = create(:amenity_visit, visit: visit, arrives: 1.week.ago, departs: Time.current)
      amenity_visit4 = create(:amenity_visit, visit: visit, arrives: Time.current, departs: 1.day.from_now)
      amenity_visit5 = create(:amenity_visit, visit: visit, arrives: 1.week.ago, departs: 1.day.ago)

      results = AmenityVisit.on_date(Date.current)

      expect(results).to eq [amenity_visit1, amenity_visit2, amenity_visit3, amenity_visit4]
    end
  end

  describe ".with_amenity_group" do
    context "when group numbers are given" do
      it "returns only the amenity visits whose amenity is in one of those groups" do
        amenity_visit1 = create(:amenity_visit, amenity: create(:amenity, group_number: "1"))
        create(:amenity_visit, amenity: create(:amenity, group_number: "2"))
        amenity_visit3 = create(:amenity_visit, amenity: create(:amenity, group_number: "3"))

        results = AmenityVisit.with_amenity_group(["1", "3"])

        expect(results).to match_array [amenity_visit1, amenity_visit3]
      end
    end

    context "when group numbers are nil" do
      it "returns every amenity visit" do
        amenity_visits = [
          create(:amenity_visit, amenity: create(:amenity, group_number: "1")),
          create(:amenity_visit, amenity: create(:amenity, group_number: "2"))
        ]

        expect(AmenityVisit.with_amenity_group(nil)).to match_array amenity_visits
      end
    end

    context "when group numbers are empty" do
      it "returns every amenity visit" do
        amenity_visits = [
          create(:amenity_visit, amenity: create(:amenity, group_number: "1")),
          create(:amenity_visit, amenity: create(:amenity, group_number: "2"))
        ]

        expect(AmenityVisit.with_amenity_group([])).to match_array amenity_visits
      end
    end
  end

  describe ".with_visit_status" do
    context "when given status is present" do
      it "returns amenity visits associated with visit with the given status" do
        visit1 = create(:visit, status: :approved)
        visit2 = create(:visit, status: :incomplete)
        amenity_visit1 = create(:amenity_visit, visit: visit1)
        amenity_visit2 = create(:amenity_visit, visit: visit2)
        amenity_visit3 = create(:amenity_visit, visit: visit1)

        results1 = AmenityVisit.with_visit_status(:approved)
        results2 = AmenityVisit.with_visit_status(:incomplete)

        expect(results1).to eq [amenity_visit1, amenity_visit3]
        expect(results2).to eq [amenity_visit2]
      end
    end

    context "when given status is NOT present" do
      it "returns all amenity visits" do
        visit1 = create(:visit, status: :approved)
        visit2 = create(:visit, status: :incomplete)
        amenity_visit1 = create(:amenity_visit, visit: visit1)
        amenity_visit2 = create(:amenity_visit, visit: visit2)
        amenity_visit3 = create(:amenity_visit, visit: visit1)

        results = AmenityVisit.with_visit_status(nil)

        expect(results).to eq [amenity_visit1, amenity_visit2, amenity_visit3]
      end
    end
  end
end
