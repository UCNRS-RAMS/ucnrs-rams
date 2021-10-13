require "rails_helper"

RSpec.describe Visit, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:reserve) }
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:short_name).to(:reserve).with_prefix }
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

  describe "enums" do
    it "has the right .project_type_options" do
      expect(Visit.project_type_options).to eq ({
        "research" => "research",
        "university class" => "university class",
        "meeting or conference" => "meeting or conference",
        "public use" => "public use",
      })
    end

    it "has the right .public_use_categories" do
      expect(Visit.public_use_categories).to eq ({
        "general-use" => "general-use",
        "community-event" => "community-event",
        "fundraiser" => "fundraiser",
        "k-12-class" => "k-12-class",
        "private-class" => "private-class",
        "volunteer" => "volunteer",
      })
    end
  end
end
