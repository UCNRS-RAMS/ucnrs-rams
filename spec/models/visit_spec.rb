require "rails_helper"

RSpec.describe Visit, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:reserve) }
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:short_name).to(:reserve).with_prefix }
  end

  describe "enums" do
    it do
      is_expected.to define_enum_for(:status).with_values({
        approved: "Approved",
        pending: "Pending approval",
        cancelled: "Cancelled",
        temp: "Temp",
      }).backed_by_column_of_type(:string)
    end

    it do
      is_expected.to define_enum_for(:project_type).with_values({
        research: "research",
        university_class: "university class",
        meeting_or_conference: "meeting or conference",
        public_use: "public use",
      }).backed_by_column_of_type(:string)
    end

    it do
      is_expected.to define_enum_for(:public_use_category).with_values({
        general_use: "general-use",
        community_event: "community-event",
        fundraiser: "fundraiser",
        k_12_class: "k-12-class",
        private_class: "private-class",
        volunteer: "volunteer",
      }).backed_by_column_of_type(:string)
    end
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
