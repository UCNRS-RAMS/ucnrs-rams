require "rails_helper"

RSpec.describe Visit, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:reserve) }
    it { is_expected.to have_many(:amenity_visits).dependent(:destroy) }
    it { is_expected.to have_many(:amenities).through(:amenity_visits) }
    it { is_expected.to have_many(:user_visits).dependent(:destroy) }
    it { is_expected.to have_many(:visitors).through(:user_visits).source(:user) }
    it { is_expected.to have_many(:reserve_notes) }
    it { is_expected.to have_many(:invoices) }
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
    it { is_expected.to delegate_method(:title).to(:project).with_prefix }
    it { is_expected.to delegate_method(:full_name).to(:user).with_prefix }
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

  describe "#project_type" do
    it "returns 'project.project_type' if project is present" do
      project = create(:project)
      visit = create(:visit, project: project)

      results = visit.project_type

      expect(results).to eq(project.project_type)
    end

    it "returns 'project.project_type' if project is present" do
      visit = build(:visit, project: nil)

      expect(visit.project_type).to be_nil
    end
  end

  describe ".recent_start_date_first" do
    it "returns records in reverse chronological order by starts_at date" do
      one = travel_to(1.week.ago) { create(:visit, starts_at: Date.current) }
      two = travel_to(1.month.ago) { create(:visit, starts_at: Date.current) }
      three = create(:visit, starts_at: Date.current)

      results = Visit.recent_start_date_first

      expect(results).to eq [three, one, two]
    end
  end

  describe ".ordered_by_visit_date" do
    it "returns records in reverse chronological order by user_visits earliest arrival" do
      visit1 = create(:visit, starts_at: 3.months.ago, ends_at: Date.current)
      visitor1 = create(:user_visit, visit: visit1, arrives_at: 2.months.ago, departs_at: 1.month.ago)
      visit2 = create(:visit, starts_at: 3.months.ago, ends_at: Date.current)
      visitor2 = create(:user_visit, visit: visit2, arrives_at: 2.weeks.ago, departs_at: 1.week.ago)

      results = Visit.ordered_by_visit_date

      expect(results).to eq [visit2, visit1]
    end
  end

  describe ".by_reserve" do
    context "when not present? is passed in" do
      it "returns all visit records" do
        reserve = create(:reserve)
        visit1 = create(:visit, reserve: reserve)
        visit2 = create(:visit, reserve: reserve)
        visit3 = create(:visit)

        results = Visit.by_reserve(nil)

        expect(results).to eq [visit1, visit2, visit3]
      end
    end

    context "when a reserve is given" do
      it "returns all visit records for that reserve" do
        reserve = create(:reserve)
        visit1 = create(:visit, reserve: reserve)
        visit2 = create(:visit, reserve: reserve)
        visit3 = create(:visit)

        results = Visit.by_reserve(reserve)

        expect(results).to eq [visit1, visit2]
      end
    end
  end

  describe ".for_status" do
    context "when not present? is passed in" do
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

    context "when 'status' is passed in" do
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
      reserve1 = create(:reserve, short_name: "SRR")
      reserve2 = create(:reserve, short_name: "UHR")
      reserve3 = create(:reserve)
      visit1 = create(:visit, user: user, reserve: reserve1)
      visit2 = create(:visit, user: user, reserve: reserve2)
      visit3 = create(:visit, reserve: reserve3)

      results = Visit.reserve_list_for_user(user)

      expected_results = {
        "SRR" => reserve1.id,
        "UHR" => reserve2.id,
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

  describe ".searching_term" do
    context "when search_filter contain only numbers" do
      it "search visit id" do
        visit = create(:visit)

        results = Visit.searching_term(visit.id.to_s)

        expect(results).to eq [visit]
      end
    end

    context "when search_filter contain not only numbers" do
      let(:user) { create(:user, last_name: "McDuck", first_name: "Scrooge", email: "s.mcd@email.me") }
      let(:visit) do
        create :visit,
          user: user,
          purpose_of_visit: "Walk around the reserve."
      end

      it "search statement of purpose" do
        results = Visit.searching_term("around the reserve")

        expect(results).to eq [visit]
      end

      it "search visit applicant last_name" do
        results = Visit.searching_term("Mcduck")

        expect(results).to eq [visit]
      end

      it "search visit applicant first_name" do
        results = Visit.searching_term("Scrooge")

        expect(results).to eq [visit]
      end

      it "search visit applicant email" do
        results = Visit.searching_term("s.mcd")

        expect(results).to eq [visit]
      end
    end
  end

  describe ".of_project_type" do
    context "when not present? is passed in" do
      it "returns all visit records" do
        project_research = create(:project, project_type: "Research")
        project_class = create(:project, project_type: "Class")
        visit1 = create(:visit, status: "approved", project: project_research)
        visit2 = create(:visit, status: "in_review", project: project_class)
        visit3 = create(:visit, status: "cancelled", project: project_research)
        visit4 = create(:visit, status: "incomplete", project: project_class)
        visit5 = create(:visit, status: "approved", project: project_research)

        results = Visit.of_project_type(nil)

        expect(results).to eq [visit1, visit2, visit3, visit4, visit5]
      end
    end

    context "when 'project_type' is passed in" do
      it "returns all visit records with the given 'project_type'" do
        project_research = create(:project, project_type: "Research")
        project_class = create(:project, project_type: "Class")
        visit1 = create(:visit, status: "approved", project: project_research)
        visit2 = create(:visit, status: "in_review", project: project_class)
        visit3 = create(:visit, status: "cancelled", project: project_research)
        visit4 = create(:visit, status: "incomplete", project: project_class)
        visit5 = create(:visit, status: "approved", project: project_research)

        results = Visit.of_project_type("research")

        expect(results).to eq [visit1, visit3, visit5]
      end
    end
  end

  describe ".sort_using" do
    it "calls the submitted_recent_first when supplied sort_option is 'submitted_recent_first'" do
      expect(Visit).to receive(:sort_using).with("submitted_recent_first").and_return(Visit.submitted_recent_first)

      Visit.sort_using "submitted_recent_first"
    end

    it "calls the recent_start_date_first when supplied sort_option is 'recent_start_date_first'" do
      expect(Visit).to receive(:sort_using).with("recent_start_date_first").and_return(Visit.recent_start_date_first)

      Visit.sort_using "recent_start_date_first"
    end

    it "returns all when supplied sort_option is not present" do
      expect(Visit).to receive(:sort_using).and_return(Visit.all)

      Visit.sort_using ""
    end
  end

  describe ".with_report_access" do
    context "when the passed status category is 1" do
      it "returns visit with report_access of 1" do
        visit1 = create(:visit, report_access: 1)
        visit2 = create(:visit, report_access: 0)
        visit3 = create(:visit, report_access: 1)
        visit4 = create(:visit, report_access: 0)

        results = Visit.with_report_access 1

        expect(results).to eq [visit1, visit3]
      end
    end

    context "when the passed status category is 0" do
      it "returns visit with report_access of 0" do
        visit1 = create(:visit, report_access: 1)
        visit2 = create(:visit, report_access: 0)
        visit3 = create(:visit, report_access: 1)
        visit4 = create(:visit, report_access: 0)

        results = Visit.with_report_access 0

        expect(results).to eq [visit2, visit4]
      end
    end
  end

  describe ".using_amenity" do
    context "when the input is not 'present?'" do
      it "returns all visit records" do
        amenity = create(:amenity)
        visit1 = create(:visit, report_access: 1)
        visit2 = create(:visit, report_access: 0)
        amenity_visit = create(:amenity_visit, amenity: amenity, visit: visit1, invoice_id: nil)

        results = Visit.using_amenity nil

        expect(results).to eq [visit1, visit2]
      end
    end

    context "when an amenity is passed in" do
      it "returns visit using the amenity" do
        amenity = create(:amenity)
        visit1 = create(:visit, report_access: 1)
        visit2 = create(:visit, report_access: 0)
        amenity_visit = create(:amenity_visit, amenity: amenity, visit: visit1)

        results = Visit.using_amenity amenity

        expect(results).to eq [visit1]
      end
    end
  end

  describe ".having_between_time_for" do
    context "when the supplied date_range_option: is ':visit_date_range'" do
      it "calls the DateQuery.having_between_time_for with types :ends_at and :starts_at" do
        date1 = Date.new(1969, 7, 20)
        date2 = Date.new(1980, 7, 31)

        allow(DateQuery).to receive(:call)

        Visit.having_between_time_for(date_range_option: :visit_date_range, date_start: date1, date_end: date2)

        expect(DateQuery).to have_received(:call).with(
          Visit,
          date_start_type: :ends_at,
          date_start: date1,
          date_end_type: :starts_at,
          date_end: date2
        )
      end
    end

    context "when supplied date_range_option doesn't match any case" do
      it "returns all visits" do
        date1 = Date.new(1969, 7, 20)
        date2 = Date.new(1980, 7, 31)
  
        results = Visit.having_between_time_for(date_range_option: :non_existent_case, date_start: date1, date_end: date2)
  
        expect(results).to eq Visit.all
      end
    end
  end

  describe ".submitted_recent_first" do
    it "returns records in reverse chronological order by submitted_at date" do
      visit1 = travel_to(1.week.ago) { create(:visit, submitted_at: Date.current) }
      visit2 = travel_to(1.month.ago) { create(:visit, submitted_at: Date.current) }
      visit3 = create(:visit, submitted_at: Date.current)

      results = Visit.submitted_recent_first

      expect(results).to eq [visit3, visit1, visit2]
    end
  end

  describe "#starts_at" do
    context "when attribute starts_at is present" do
      it "returns datetime from the attribute starts_at" do
        time = 1.month.ago.round
        visit = create(:visit, starts_at: time)

        results = visit.starts_at

        expect(results).to eq time
      end
    end

    context "when attribute starts_at is not present" do
      it "returns datetime from the attributes start_date + start_time" do
        date = 1.week.ago.to_date
        time = Time.current.round
        visit = create(:visit, starts_at: nil, start_date: date, start_time: time)

        results = visit.starts_at

        expect(results).to eq time.change(year: date.year, month: date.month, day: date.day)
      end
    end
  end

  describe "#ends_at" do
    context "when attribute ends_at is present" do
      it "returns datetime from the attribute ends_at" do
        time = 1.month.ago.round
        visit = create(:visit, ends_at: time)

        results = visit.ends_at

        expect(results).to eq time
      end
    end

    context "when attribute ends_at is not present" do
      it "returns datetime from the attributes end_date + end_time" do
        date = 1.week.ago.to_date
        time = Time.current.round
        visit = create(:visit, ends_at: nil, start_date: 2.week.ago.to_date, end_time: Time.current, end_date: date, end_time: time)

        results = visit.ends_at

        expect(results).to eq time.change(year: date.year, month: date.month, day: date.day)
      end
    end
  end
end
