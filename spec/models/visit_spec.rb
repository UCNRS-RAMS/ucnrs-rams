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
    it { is_expected.to have_many(:reserve_notes) }
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
    it { is_expected.to delegate_method(:name).to(:reserve).with_prefix }
  end

  describe "enums" do
    it do
      is_expected.to define_enum_for(:status).with_values({
        approved: "approved",
        in_review: "in_review",
        cancelled: "cancelled",
        incomplete: "incomplete",
        denied: "denied",
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
      visit1 = create(:visit, start_date: 3.months.ago, end_date: Date.current)
      visitor1 = create(:user_visit, visit: visit1, arrives_at: 2.months.ago, departs_at: 1.month.ago)
      visit2 = create(:visit, start_date: 3.months.ago, end_date: Date.current)
      visitor2 = create(:user_visit, visit: visit2, arrives_at: 2.weeks.ago, departs_at: 1.week.ago)

      results = Visit.ordered_by_visit_date

      expect(results).to eq [visit2, visit1]
    end
  end

  describe ".by_reserve" do
    context "when a reserve id passed in is nil" do
      it "returns all visit records" do
        reserve = create(:reserve)
        visit1 = create(:visit, reserve: reserve)
        visit2 = create(:visit, reserve: reserve)
        visit3 = create(:visit)

        results = Visit.by_reserve(nil)

        expect(results).to eq [visit1, visit2, visit3]
      end
    end

    context "when a reserve id is passed in" do
      it "returns all visit records for that reserve" do
        reserve = create(:reserve)
        visit1 = create(:visit, reserve: reserve)
        visit2 = create(:visit, reserve: reserve)
        visit3 = create(:visit)

        results = Visit.by_reserve(reserve.id)

        expect(results).to eq [visit1, visit2]
      end
    end
  end

  describe ".for_status" do
    context "when status filter passed in is nil" do
      it "returns all visit records" do
        visit1 = create(:visit, status: "approved")
        visit2 = create(:visit, status: "in_review")
        visit3 = create(:visit, status: "cancelled")
        visit4 = create(:visit, status: "incomplete")
        visit5 = create(:visit, status: "approved")

        results = Visit.for_status(nil)

        expect(results).to eq [visit1, visit2, visit3, visit4, visit5]
      end
    end

    context "when status filter passed" do
      it "returns all visit records with the given status" do
        visit1 = create(:visit, status: "approved")
        visit2 = create(:visit, status: "in_review")
        visit3 = create(:visit, status: "cancelled")
        visit4 = create(:visit, status: "incomplete")
        visit5 = create(:visit, status: "approved")

        results = Visit.for_status("approved")

        expect(results).to eq [visit1, visit5]
      end
    end
  end

  describe ".visit_requests_for_user" do
    it "returns all visit records that the given user is participating in and that the user created" do
      user = create(:user)
      visit1 = create(:visit, user: user)
      visit2 = create(:visit, user: user)
      visit3 = create(:visit)
      visit4 = create(:visit)
      create(:user_visit, visit: visit4, user: user)
      visit5 = create(:visit, user: user)
      create(:user_visit, visit: visit5, user: user)
      visit6 = create(:visit)
      create(:user_visit, visit: visit6)

      results = Visit.visit_requests_for_user(user)

      expect(results).to eq [visit1, visit2, visit4, visit5]
    end
  end

  describe ".reserve_list_for_user" do
    it "returns an hash of reserve ids and reserve names of the user visits" do
      user = create(:user)
      reserve1 = create(:reserve, name: "Snake River Reserve")
      reserve2 = create(:reserve, name: "Under the Hill Reserve")
      reserve3 = create(:reserve)
      visit1 = create(:visit, user: user, reserve: reserve1)
      visit2 = create(:visit, user: user, reserve: reserve2)
      visit3 = create(:visit, reserve: reserve3)

      results = Visit.reserve_list_for_user(user)

      expected_results = {
        "Snake River Reserve" => reserve1.id,
        "Under the Hill Reserve" => reserve2.id,
      }

      expect(results).to eq expected_results
    end
  end

  describe ".participating_visit_ids" do
    it "returns an array of visit ids user is participating" do
      user = create(:user)
      visit1 = create(:visit)
      create(:user_visit, visit: visit1, user: user)
      visit2 = create(:visit, user: user)
      create(:user_visit, visit: visit2, user: user)
      visit3 = create(:visit)
      create(:user_visit, visit: visit3)

      results = Visit.participating_visit_ids(user)

      expect(results).to eq [visit1.id, visit2.id]
    end
  end

  describe ".applicant_visit_ids" do
    it "returns an array of visit ids user creates" do
      user = create(:user)
      visit1 = create(:visit, user: user)
      visit2 = create(:visit, user: user)
      visit3 = create(:visit)

      results = Visit.applicant_visit_ids(user)

      expect(results).to eq [visit1.id, visit2.id]
    end
  end
end
