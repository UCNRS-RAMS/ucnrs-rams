require "rails_helper"

RSpec.describe UserVisit, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:visit) }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:institution) }
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
          visit = build(:visit, start_date: Date.current, end_date: Date.current + 5.days)
          user_visit = build(:user_visit, arrives_at: visit.start_date - 1.day,
            departs_at: visit.end_date, visit: visit)

          user_visit.save

          expect(user_visit).not_to be_valid
          expect(user_visit.errors.messages[:arrives_at]).to include("must be after visit start date")
        end
      end
      context "when the departs_at is after end_date" do
        it "adds error for departs_at" do
          visit = build(:visit, start_date: Date.current, end_date: Date.current + 5.days)
          user_visit = build(:user_visit, arrives_at: visit.start_date,
            departs_at: visit.end_date + 1.day, visit: visit)

          user_visit.save

          expect(user_visit).not_to be_valid
          expect(user_visit.errors.messages[:departs_at]).to include("must be before visit end date")
        end
      end
      context "when the arrives_at and departs_at are within the visit start_date and end_date" do
        it "is valid" do
          visit = build(:visit, start_date: Date.current, end_date: Date.current + 5.days)
          user_visit = build(:user_visit, arrives_at: visit.start_date + 1.day,
            departs_at: visit.end_date, visit: visit)

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
end
