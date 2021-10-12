require "rails_helper"

RSpec.describe Visit, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:reserve) }
  end

  describe ".recent_start_date_first" do
    it "returns records in reverse chronological order by start_date" do
      one = travel_to(1.week.ago) { create(:visit, start_date: Date.current) }
      two = travel_to(1.month.ago) { create(:visit, start_date: Date.current) }
      three = create(:visit, start_date: Date.current)

      results = Visit.recent_start_date_first

      expect(results).to eq [three, one, two]
    end
  end
end
