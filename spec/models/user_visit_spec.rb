require "rails_helper"

RSpec.describe UserVisit, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:visit) }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:institution) }
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:full_name).to(:user).with_prefix }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:arrives_at) }
    it { is_expected.to validate_presence_of(:departs_at) }

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

    describe "date_range_within_visit_range" do
      context "when the arrives_at is before visit start_date" do
        it "adds error for arrives_at" do
          visit = build(:visit, starts_at: Date.current, ends_at: Date.current + 5.days)
          user_visit = build(:user_visit, arrives_at: visit.starts_at - 1.day,
            departs_at: visit.ends_at, visit: visit)

          user_visit.save

          expect(user_visit).not_to be_valid
          expect(user_visit.errors.messages[:arrives_at]).to include("must be after visit start date")
        end
      end

      context "when the departs_at is after end_date" do
        it "adds error for departs_at" do
          visit = build(:visit, starts_at: Date.current, ends_at: Date.current + 5.days)
          user_visit = build(:user_visit, arrives_at: visit.starts_at,
            departs_at: visit.ends_at + 1.day, visit: visit)

          user_visit.save

          expect(user_visit).not_to be_valid
          expect(user_visit.errors.messages[:departs_at]).to include("must be before visit end date")
        end
      end

      context "when the arrives_at and departs_at are within the visit start_date and end_date" do
        it "is valid" do
          visit = build(:visit, starts_at: Date.current, ends_at: Date.current + 5.days)
          user_visit = build(:user_visit, arrives_at: visit.starts_at + 1.day,
            departs_at: visit.ends_at, visit: visit)

          user_visit.save

          expect(user_visit).to be_valid
        end
      end
    end
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

  describe ".at_reserve" do
    it "returns user visits from the given reserve" do
      reserve1 = create(:reserve)
      reserve2 = create(:reserve)
      visit1 = create(:visit, reserve: reserve1)
      visit2 = create(:visit, reserve: reserve2)
      user_visit1 = create(:user_visit, visit: visit1)
      user_visit2 = create(:user_visit, visit: visit2)
      user_visit3 = create(:user_visit, visit: visit1)

      results = UserVisit.at_reserve(reserve1)

      expect(results).to eq [user_visit1, user_visit3]
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
end
