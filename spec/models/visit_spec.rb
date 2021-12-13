require "rails_helper"

RSpec.describe Visit, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:reserve) }
    it { is_expected.to have_many(:amenity_visits) }
    it { is_expected.to have_many(:amenities).through(:amenity_visits) }
    it { is_expected.to have_many(:user_visits) }
    it { is_expected.to have_many(:visitors).through(:user_visits).source(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:purpose_of_visit) }
    it { is_expected.to validate_presence_of(:project_type) }
    it { is_expected.to validate_presence_of(:start_time) }
    it { is_expected.to validate_presence_of(:end_time) }
    it { is_expected.to validate_date(:end_date).is_after(:start_date) }

    describe "when public-use" do
      before { subject.project_type = :public_use }
      it { is_expected.to validate_presence_of(:public_use_category) }
    end

    describe "when not public-use" do
      before { subject.project_type = :research }
      it { is_expected.to_not validate_presence_of(:public_use_category) }
    end
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:short_name).to(:reserve).with_prefix }
  end

  describe "enums" do
    it do
      is_expected.to define_enum_for(:status).with_values({
        approved: "approved",
        in_review: "in_review",
        cancelled: "cancelled",
        incomplete: "incomplete",
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

  describe ".ordered_by_visit_date" do
    it "returns records in reverse chronological order by user_visits earliest arrival" do
      visit1 = create(:visit)
      visitor1 = create(:user_visit, visit: visit1, arrives_at: 2.month.ago, departs_at: 1.month.ago)

      visit2 = create(:visit)
      visitor2 = create(:user_visit, visit: visit2, arrives_at: 2.week.ago, departs_at: 1.week.ago)

      results = Visit.ordered_by_visit_date

      expect(results).to eq [visit2, visit1]
    end
  end

  describe "#visit_requests_for_user" do
    it "returns visit records having user_visits by the user_id given" do
      user1 = create(:user)
      visit1 = create(:visit)
      user_visit1 = create(:user_visit, visit: visit1, user: user1)
      visit2 = create(:visit)
      user_visit2 = create(:user_visit, visit: visit2, user: create(:user))
      visit3 = create(:visit)
      user_visit3 = create(:user_visit, visit: visit3, user: user1)

      results = Visit.visit_requests_for_user(user: user1)

      expect(results).to eq [visit1, visit3]
    end
  end
end
