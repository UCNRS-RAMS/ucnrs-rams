require "rails_helper"

RSpec.describe UserVisit, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:visit) }
    it { is_expected.to belong_to(:user) }
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
