require "rails_helper"

RSpec.describe UserVisit, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:visit) }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:institution) }
    it { is_expected.to have_many(:logs) }
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:full_name).to(:user).with_prefix }
  end

  describe "validations" do
    it { is_expected.to validate_numericality_of(:count).is_greater_than_or_equal_to(1) }
    it { is_expected.to validate_presence_of(:arrives_at) }
    it { is_expected.to validate_presence_of(:departs_at) }
    it { is_expected.to validate_date(:departs_at).is_after(:arrives_at) }
    it { is_expected.to validate_presence_of(:role) }

    describe "arrives_at_before_departs_at" do
      context "when the arrives_at is after departs_at" do
        it "adds errors for arrives_at and departs_at" do
          user_visit = build(:user_visit, arrives_at: Time.current + 1.day,
            departs_at: Time.current)

          user_visit.save

          expect(user_visit).not_to be_valid
          expect(user_visit.errors.messages[:departs_at]).to include("must be after Arrives at")
        end
      end
      context "when the arrives_at is before departs_at" do
        it "is valid" do
          user_visit = build(:user_visit, arrives_at: Time.current + 1.day,
            departs_at: Time.current + 3.days)

          user_visit.save

          expect(user_visit).to be_valid
        end
      end
      context "when the arrives_at and departs_at are same" do
        it "is valid" do
          time = Time.current
          user_visit = build(:user_visit, arrives_at: time, departs_at: time)

          user_visit.save

          expect(user_visit).to be_valid
        end
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
      .with_suffix(true)
  end

  describe "#arrival_date" do
    it "returns the date of visit request arrival" do
      arrives_at = Time.current
      departs_at = Time.current + 1.day
      user_visit = build(:user_visit, arrives_at: arrives_at, departs_at: departs_at)

      expect(user_visit.arrival_date).to eq arrives_at.to_date
    end
  end

  describe "#departure_date" do
    it "returns the date of visit request departure" do
      arrives_at = Time.current
      departs_at = Time.current + 1.day
      user_visit = build(:user_visit, arrives_at: arrives_at, departs_at: departs_at)

      expect(user_visit.departure_date).to eq departs_at.to_date
    end
  end

  describe ".in_visit_amenities_range" do
    it "returns true if user_visits in amenity date range" do
      visit = create(:visit, starts_at: 3.week.ago, ends_at: 3.week.from_now)
      amenity_visit1 = create(:amenity_visit, visit: visit, arrives_on: 2.week.ago, departs_on: 2.week.from_now)
      amenity_visit2 = create(:amenity_visit, visit: visit, arrives_on: 2.week.ago, departs_on: Time.current)

      user_visit1 = create(:user_visit, visit: visit, arrives_at: 1.week.ago, departs_at: Time.current)
      user_visit2 = create(:user_visit, visit: visit, arrives_at: 1.week.ago, departs_at: 1.week.ago)

      expect(visit.user_visits.in_visit_amenities_range?(visit)).to be_truthy
    end

    it "returns false if user_visits not in amenity date range" do
      visit = create(:visit, starts_at: 3.week.ago, ends_at: 4.week.from_now)
      amenity_visit1 = create(:amenity_visit, visit: visit, arrives_on: 2.week.ago, departs_on: 2.week.from_now)
      amenity_visit2 = create(:amenity_visit, visit: visit, arrives_on: 2.week.ago, departs_on: Time.current)

      user_visit1 = create(:user_visit, visit: visit, arrives_at: 3.week.ago, departs_at: 3.week.from_now)

      expect(visit.user_visits.in_visit_amenities_range?(visit)).to be_falsy
    end
  end

  describe ".at_reserve" do
    context "when given reserve record or reserve id" do
      it "returns user_visits that belongs to the given reserve through visit" do
        reserve = create(:reserve)
        visit = create(:visit, reserve: reserve)
        user_visit1 = create(:user_visit, visit: visit)
        user_visit2 = create(:user_visit, visit: create(:visit))

        results = UserVisit.at_reserve(reserve)

        expect(results.map(&:id)).to eq [user_visit1.id]
      end
    end

    context "when not given reserve record or reserve id" do
      it "returns all user_visits" do
        reserve = create(:reserve)
        visit = create(:visit, reserve: reserve)
        user_visit1 = create(:user_visit, visit: visit)
        user_visit2 = create(:user_visit, visit: create(:visit))

        results = UserVisit.at_reserve(nil)

        expect(results.map(&:id)).to eq [user_visit1.id, user_visit2.id]
      end
    end
  end

  describe ".on_date" do
    it "returns user visits with a given date on/or between the arrives_at and departs_at dates" do
      visit = create(:visit, starts_at: 3.week.ago, ends_at: 3.week.from_now)
      user_visit1 = create(:user_visit, visit: visit, arrives_at: 1.week.ago, departs_at: 1.week.from_now)
      user_visit2 = create(:user_visit, visit: visit, arrives_at: Time.current, departs_at:Time.current)
      user_visit3 = create(:user_visit, visit: visit, arrives_at: 1.week.ago, departs_at: Time.current)
      user_visit4 = create(:user_visit, visit: visit, arrives_at: Time.current, departs_at: 1.day.from_now)
      user_visit5 = create(:user_visit, visit: visit, arrives_at: 1.week.ago, departs_at: 1.day.ago)

      results = UserVisit.on_date(Date.current)

      expect(results).to eq [user_visit1, user_visit2, user_visit3, user_visit4]
    end
  end

  describe ".having_between_time_for" do
    context "when supplied date_start: and date_end: is present" do
      it "returns user_visits that start and end date within its arrival and departure" do
        time = Time.current
        user_visit1 = create(:user_visit, arrives_at: time, departs_at: time)
        user_visit2 = create(:user_visit, arrives_at: time.yesterday, departs_at: time.yesterday)
        user_visit3 = create(:user_visit, arrives_at: time.yesterday, departs_at: time.tomorrow)
        user_visit4 = create(:user_visit, arrives_at: time.tomorrow, departs_at: time.tomorrow)
        user_visit5 = create(:user_visit, arrives_at: time, departs_at: time.tomorrow)
        user_visit6 = create(:user_visit, arrives_at: time.yesterday, departs_at: time)

        results = UserVisit.having_between_time(date_start: time.to_date, date_end: time.to_date)

        expect(results.to_a).to eq [user_visit1, user_visit3, user_visit5, user_visit6]
      end
    end

    context "when supplied date_start: and date_end: is NOT present" do
      it "returns all" do
        time = Time.current
        user_visit1 = create(:user_visit, arrives_at: time.to_date, departs_at: time.to_date)
        user_visit2 = create(:user_visit, arrives_at: time.yesterday.to_date, departs_at: time.yesterday.to_date)
        user_visit3 = create(:user_visit, arrives_at: time.yesterday.to_date, departs_at: time.tomorrow.to_date)
        user_visit4 = create(:user_visit, arrives_at: time.tomorrow.to_date, departs_at: time.tomorrow.to_date)
        user_visit5 = create(:user_visit, arrives_at: time.to_date, departs_at: time.tomorrow.to_date)
        user_visit6 = create(:user_visit, arrives_at: time.yesterday.to_date, departs_at: time.to_date)

        results = UserVisit.having_between_time(date_start: nil, date_end: nil)

        expect(results).to eq UserVisit.all
      end
    end
  end

  describe ".with_visit_status" do
    context "when given status is present" do
      it "returns user visits associated with visit with the given status" do
        visit1 = create(:visit, status: :approved)
        visit2 = create(:visit, status: :incomplete)
        user_visit1 = create(:user_visit, visit: visit1)
        user_visit2 = create(:user_visit, visit: visit2)
        user_visit3 = create(:user_visit, visit: visit1)

        results1 = UserVisit.with_visit_status(:approved)
        results2 = UserVisit.with_visit_status(:incomplete)

        expect(results1).to eq [user_visit1, user_visit3]
        expect(results2).to eq [user_visit2]
      end
    end

    context "when given status is NOT present" do
      it "returns all user visits" do
        visit1 = create(:visit, status: :approved)
        visit2 = create(:visit, status: :incomplete)
        user_visit1 = create(:user_visit, visit: visit1)
        user_visit2 = create(:user_visit, visit: visit2)
        user_visit3 = create(:user_visit, visit: visit1)

        results = UserVisit.with_visit_status(nil)

        expect(results).to eq [user_visit1, user_visit2, user_visit3]
      end
    end
  end
end
