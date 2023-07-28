require "rails_helper"

RSpec.describe Project, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:reserve).optional(true) }
    it { is_expected.to belong_to(:owner).class_name("User").with_foreign_key(:user_id) }
    it { is_expected.to belong_to(:applicant).class_name("User") }
    it { is_expected.to have_many(:visits) }
    it { is_expected.to have_many(:team_memberships).class_name("ProjectTeamMembership") }
    it { is_expected.to have_many(:team_members).class_name("User") }
    it { is_expected.to have_many(:project_permit_answers) }
    it { is_expected.to have_many(:fundings) }
    it { is_expected.to have_many(:reserve_notes) }
  end

  describe "validations" do
    context "when the project_type is research" do
      subject { Project.new(project_type: :research) }
      it { is_expected.to validate_presence_of(:title) }
      it { is_expected.to validate_presence_of(:abstract) }
      it { is_expected.to validate_presence_of(:discipline) }
      it { is_expected.to validate_presence_of(:start_date) }
      it { is_expected.to validate_presence_of(:end_date) }
      it { is_expected.to validate_date(:end_date).is_after(:start_date) }
      it { is_expected.to validate_presence_of(:method_description) }
      it { is_expected.to validate_booleanish_values(:method_remove_organisms) }
      it { is_expected.to validate_booleanish_values(:method_transfer_organisms) }
      it { is_expected.to validate_booleanish_values(:method_study_non_native_species) }
      it { is_expected.to validate_booleanish_values(:method_chemicals) }
      it { is_expected.to validate_booleanish_values(:method_soil_disturbance) }
      it { is_expected.to validate_booleanish_values(:method_long_term_structures) }

      it { is_expected.not_to validate_presence_of(:course_title) }
      it { is_expected.not_to validate_presence_of(:course_number) }

      context "when discipline is 'Other'" do
        subject { Project.new(project_type: :research, discipline: "Other") }
        it { is_expected.to validate_presence_of(:discipline_other) }
      end

      context "when discipline is not 'Other'" do
        subject { Project.new(project_type: :research, discipline: "Agriculture") }
        it { is_expected.not_to validate_presence_of(:discipline_other) }
      end

      context "when method_chemicals is true" do
        subject { Project.new(project_type: :research, method_chemicals: true) }
        it { is_expected.to validate_presence_of(:method_chemicals_list) }
      end

      context "when method_chemicals is false" do
        subject { Project.new(project_type: :research, method_chemicals: false) }
        it { is_expected.not_to validate_presence_of(:method_chemicals_list) }
      end

      context "involvement selections" do
        it "is valid and has no errors when at least on involvement is selected" do
          project = build(
            :project,
            project_type: :research,
            involves_mammals: true,
            involves_reptiles: false,
            involves_amphibians: false,
            involves_fish: false,
            involves_birds: false,
            involves_plants_fungi_soil: false,
            involves_none: false,
            involves_threatened_endangered_species: false,
          )

          project.validate

          expect(project).to be_valid
          expect(project.errors.full_messages).to be_empty
        end

        it "is invalid and has an error when no involvements are selected" do
          project = build(
            :project,
            project_type: :research,
            involves_mammals: false,
            involves_reptiles: false,
            involves_amphibians: false,
            involves_fish: false,
            involves_birds: false,
            involves_plants_fungi_soil: false,
            involves_none: false,
            involves_threatened_endangered_species: false,
          )

          project.validate

          expect(project).not_to be_valid
          expect(project.errors.full_messages).to eq ["Involvements must select at least one"]
        end
      end
    end

    context "when the project_type is class" do
      subject { Project.new(project_type: :class) }
      it { is_expected.to validate_presence_of(:title) }
      it { is_expected.to validate_presence_of(:course_title) }
      it { is_expected.to validate_presence_of(:course_number) }
      it { is_expected.to validate_presence_of(:discipline) }
      it { is_expected.to validate_presence_of(:start_date) }
      it { is_expected.to validate_presence_of(:end_date) }
      it { is_expected.to validate_date(:end_date).is_after(:start_date) }
      it { is_expected.to validate_presence_of(:method_description) }
      it { is_expected.to validate_booleanish_values(:method_remove_organisms) }
      it { is_expected.to validate_booleanish_values(:method_transfer_organisms) }
      it { is_expected.to validate_booleanish_values(:method_study_non_native_species) }
      it { is_expected.to validate_booleanish_values(:method_chemicals) }
      it { is_expected.to validate_booleanish_values(:method_soil_disturbance) }
      it { is_expected.to validate_booleanish_values(:method_long_term_structures) }

      it { is_expected.not_to validate_presence_of(:abstract) }

      context "when discipline is 'Other'" do
        subject { Project.new(project_type: :class, discipline: "Other") }
        it { is_expected.to validate_presence_of(:discipline_other) }
      end

      context "when discipline is not 'Other'" do
        subject { Project.new(project_type: :class, discipline: "Agriculture") }
        it { is_expected.not_to validate_presence_of(:discipline_other) }
      end

      context "when method_chemicals is true" do
        subject { Project.new(project_type: :class, method_chemicals: true) }
        it { is_expected.to validate_presence_of(:method_chemicals_list) }
      end

      context "when method chemicals is false" do
        subject { Project.new(project_type: :class, method_chemicals: false) }
        it { is_expected.not_to validate_presence_of(:method_chemicals_list) }
      end

      context "involvement selections" do
        it "is valid and has no errors when at least on involvement is selected" do
          project = build(
            :project,
            project_type: :class,
            involves_mammals: true,
            involves_reptiles: false,
            involves_amphibians: false,
            involves_fish: false,
            involves_birds: false,
            involves_plants_fungi_soil: false,
            involves_none: false,
            involves_threatened_endangered_species: false,
          )

          project.validate

          expect(project).to be_valid
          expect(project.errors.full_messages).to be_empty
        end

        it "is invalid and has an error when no involvements are selected" do
          project = build(
            :project,
            project_type: :class,
            involves_mammals: false,
            involves_reptiles: false,
            involves_amphibians: false,
            involves_fish: false,
            involves_birds: false,
            involves_plants_fungi_soil: false,
            involves_none: false,
            involves_threatened_endangered_species: false,
          )

          project.validate

          expect(project).not_to be_valid
          expect(project.errors.full_messages).to eq ["Involvements must select at least one"]
        end
      end
    end

    context "when the project_type is meeting" do
      subject { Project.new(project_type: :meeting) }
      it { is_expected.to validate_presence_of(:title) }
      it { is_expected.to validate_presence_of(:abstract) }
      it { is_expected.to validate_presence_of(:start_date) }
      it { is_expected.to validate_presence_of(:end_date) }
      it { is_expected.to validate_date(:end_date).is_after(:start_date) }

      it { is_expected.not_to validate_presence_of(:course_title) }

      context "when discipline is 'Other'" do
        subject { Project.new(project_type: :class, discipline: "Other") }
        it { is_expected.to validate_presence_of(:discipline_other) }
      end

      context "when discipline is not 'Other'" do
        subject { Project.new(project_type: :class, discipline: "Agriculture") }
        it { is_expected.not_to validate_presence_of(:discipline_other) }
      end
    end

    context "when the project_type is public" do
      subject { Project.new(project_type: :public_use) }
      it { is_expected.to validate_presence_of(:title) }
      it { is_expected.to validate_presence_of(:abstract) }
      it { is_expected.to validate_presence_of(:start_date) }
      it { is_expected.to validate_presence_of(:end_date) }
      it { is_expected.to validate_date(:end_date).is_after(:start_date) }

      it { is_expected.not_to validate_presence_of(:course_title) }

      context "when discipline is 'Other'" do
        subject { Project.new(project_type: :class, discipline: "Other") }
        it { is_expected.to validate_presence_of(:discipline_other) }
      end

      context "when discipline is not 'Other'" do
        subject { Project.new(project_type: :class, discipline: "Agriculture") }
        it { is_expected.not_to validate_presence_of(:discipline_other) }
      end
    end
  end

  it do
    is_expected.to define_enum_for(:status)
      .with_values(
        open: "Open",
        closed: "Closed",
        incomplete: "Incomplete",
      ).backed_by_column_of_type(:string)
  end

  it do
    is_expected.to define_enum_for(:project_type)
      .with_values(
        research: "Research",
        class: "Class",
        meeting: "Meeting",
        public_use: "Public Use",
        housing: "Housing",
      ).backed_by_column_of_type(:string)
      .with_prefix(true)
  end

  describe ".alphabetized" do
    it "returns all records ordered alphabetically by title" do
      project_c = create(:project, title: "C")
      project_a = create(:project, title: "A")
      project_b = create(:project, title: "B")

      expect(Project.alphabetized).to eq [project_a, project_b, project_c]
    end
  end

  describe ".with_active_team_member" do
    context "when the can_add_visit argument is not supplied" do
      it "returns all projects that are associated with a given user and are labeled as active" do
        first_user = create(:user)
        second_user = create(:user)
        first_project = create(:project)
        second_project = create(:project)
        third_project = create(:project)
        create(:project_team_membership, project: first_project, user: first_user, active: false)
        create(:project_team_membership, project: second_project, user: second_user, active: true)
        create(:project_team_membership, project: third_project, user: first_user, active: true)

        results = Project.with_active_team_member(user: first_user)

        expect(results).to match_array [third_project]
      end
    end

    context "when the can_add_visit argument is supplied" do
      it "returns all projects that are associated with a given user and are labeled as active and are able to add visits" do
        first_user = create(:user)
        second_user = create(:user)
        first_project = create(:project)
        second_project = create(:project)
        third_project = create(:project)
        create(:project_team_membership, project: first_project, user: first_user, active: true, can_add_visit: false)
        create(:project_team_membership, project: second_project, user: second_user, active: true, can_add_visit: true)
        create(:project_team_membership, project: third_project, user: first_user, active: true, can_add_visit: true)

        results = Project.with_active_team_member(user: first_user, can_add_visit: true)

        expect(results).to match_array [third_project]
      end
    end
  end

  describe ".recent_first" do
    it "returns records in reverse chronological order" do
      one = travel_to(1.week.ago) { create(:project) }
      two = travel_to(1.month.ago) { create(:project) }
      three = create(:project)

      results = Project.recent_first

      expect(results).to eq([three, one, two])
    end
  end

  describe ".submitted_recent_first" do
    it "returns records that have been submitted in reverse chro" do
      project_not_submitted = create(:project, submitted_at: nil)
      project_submitted_yesterday = create(:project, submitted_at: Date.yesterday)
      project_submitted_tomorrow = create(:project, submitted_at: Date.tomorrow)

      results = Project.submitted_recent_first

      expect(results).to eq([project_submitted_tomorrow, project_submitted_yesterday])
    end
  end

  describe ".ordered_by_visit_date" do
    it "orders the project records by the associated visits start_dates" do
      project1 = create(:project, title: "P1")
      project2 = create(:project, title: "P2")
      project3 = create(:project, title: "P3")
      project4 = create(:project, title: "P4")
      project5 = create(:project, title: "P5")
      project6 = create(:project, title: "P6")
      past_visit = create(:visit, project: project1, start_date: Date.current - 1.year, end_date: Date.current - 6.months)
      ongoing_visit = create(:visit, project: project2, start_date: Date.current - 1.day, end_date: Date.current + 3.days)
      null_start_date = create(:visit, project: project3, start_date: nil, end_date: nil)
      future_visit = create(:visit, project: project4, start_date: Date.current + 1.year, end_date: Date.current + 2.years)
      other_null_start_date = create(:visit, project: project5, start_date: nil, end_date: nil)
      other_ongoing_visit = create(:visit, project: project6, start_date: Date.current - 3.days, end_date: Date.current + 3.days)
      other_null_start_date2 = create(:visit, project: project1, start_date: nil, end_date: nil)

      results = Project.ordered_by_visit_date

      expect(results.map(&:title)).to eq [
        "P1",
        "P3",
        "P5",
        "P6",
        "P2",
        "P4",
      ]
    end
  end

  describe ".for_status" do
    context "when the passed status category is 'All Projects'" do
      it "returns all project records" do
        projects = create_pair(:project)

        results = Project.for_status("All Projects")

        expect(results).to match_array projects
      end
    end

    context "when the passed status category is something other than 'All Projects'" do
      it "returns the project records where the status maps to the status category" do
        incomplete_projects = create_pair(:project, status: "Incomplete")
        active_project = create(:project, status: "Open")

        results = Project.for_status("Incomplete Projects")

        expect(results).to match_array incomplete_projects
      end
    end
  end

  describe "#visits_count" do
    it "counts the number of visits associtated with a project" do
      project = create(:project)
      visit1 = create(:visit, project: project)
      visit2 = create(:visit, project: project)
      visit3 = create(:visit)

      expect(project.visits_count).to eq 2
    end
  end

  describe ".of_type" do
    it "returns all projects when the supplied type is 'all'" do
      research_project = create(:project, project_type: "Research")
      class_project = create(:project, project_type: "Class")
      meeting_project = create(:project, project_type: "Meeting")
      public_project = create(:project, project_type: "Public Use")

      results = Project.of_type("all")

      expect(results).to eq [research_project, class_project, meeting_project, public_project]
    end

    it "returns research projects when the supplied type is 'research'" do
      research_project = create(:project, project_type: "Research")
      non_research_project = create(:project, project_type: "Public Use")

      results = Project.of_type("research")

      expect(results).to eq [research_project]
    end

    it "returns class projects when the supplied type is 'university_class'" do
      class_project = create(:project, project_type: "Class")
      non_class_project = create(:project, project_type: "Public Use")

      results = Project.of_type("university_class")

      expect(results).to eq [class_project]
    end

    it "returns meeting projects when the supplied type is 'meeting_or_conference'" do
      meeting_project = create(:project, project_type: "Meeting")
      non_meeting_project = create(:project, project_type: "Public Use")

      results = Project.of_type("meeting_or_conference")

      expect(results).to eq [meeting_project]
    end

    it "returns public projects when the supplied type is 'public_use'" do
      public_project = create(:project, project_type: "Public Use")
      non_public_project = create(:project, project_type: "Meeting")

      results = Project.of_type("public_use")

      expect(results).to eq [public_project]
    end

    it "returns an empty scope when anything else is passed" do
      expect(Project.of_type("foo")).to eq []
    end
  end

  describe "#update_project_status" do
    it "assigns the project's status to 'open' if the project is 'incomplete'" do
      project = create(:project, status: :incomplete)

      project.update_project_status

      expect(project).to be_open
    end

    it "assigns the project's submitted_at field to current date and time if the project is 'incomplete'" do
      project = create(:project, status: :incomplete)

      freeze_time
      project.update_project_status

      expect(project.submitted_at).to eq Time.current
    end

    it "does nothing if the project is not 'incomplete'" do
      project = create(:project, status: :closed)

      project.update_project_status

      expect(project).to be_closed
    end
  end

  describe ".having_between_time_for" do
    it "calls the DateQuery.having_between_time_for when supplied date_range_option: is ':project_submitted_date_range'" do
      date1 = Date.new(1969, 7, 20)
      date2 = Date.new(1980, 7, 31)

      allow(DateQuery).to receive(:call)

      Project.having_between_time_for(date_range_option: :project_submitted_date_range, date_start: date1, date_end: date2)

      expect(DateQuery).to have_received(:call).with(
        Project,
        date_start_type: :submitted_at,
        date_start: date1,
        date_end_type: :submitted_at,
        date_end: date2
      )
    end

    it "calls the DateQuery.having_between_time_for when supplied date_range_option: is ':project_date_range'" do
      date1 = Date.new(1969, 7, 20)
      date2 = Date.new(1980, 7, 31)

      allow(DateQuery).to receive(:call)

      Project.having_between_time_for(date_range_option: :project_date_range, date_start: date1, date_end: date2)

      expect(DateQuery).to have_received(:call).with(
        Project,
        date_start_type: :end_date,
        date_start: date1,
        date_end_type: :start_date,
        date_end: date2
      )
    end

    it "calls the .having_visit_end_date_after and .having_visit_start_date_before when supplied date_range_option is ':visit_date_range'" do
      date1 = Date.new(1969, 7, 20)
      date2 = Date.new(1980, 7, 31)

      expect(Project).to receive(:having_between_time_for).with({
          date_range_option: :visit_date_range,
          date_start: date1,
          date_end: date2,
        }).and_return(Project.having_visit_end_date_after(date1).having_visit_start_date_before(date2))

      Project.having_between_time_for(date_range_option: :visit_date_range, date_start: date1, date_end: date2)
    end

    it "calls the .having_invoice_created_start_date_after and .having_invoice_created_end_date_before when supplied date_range_option is ':invoice_created_at_date_range'" do
      date1 = Date.new(1969, 7, 20)
      date2 = Date.new(1980, 7, 31)

      expect(Project).to receive(:having_between_time_for).with({
          date_range_option: :invoice_created_at_date_range,
          date_start: date1,
          date_end: date2,
        }).and_return(Project.having_invoice_created_start_date_after(date1).having_invoice_created_end_date_before(date2))

      Project.having_between_time_for(date_range_option: :invoice_created_at_date_range, date_start: date1, date_end: date2)
    end

    it "returns self.all when supplied date_range_option doesn't match any case" do
      date1 = Date.new(1969, 7, 20)
      date2 = Date.new(1980, 7, 31)

      results = Project.having_between_time_for(date_range_option: :non_existent_case, date_start: date1, date_end: date2)

      expect(results).to eq Project.all
    end
  end

  describe ".with_visits_at_reserve" do
    it "returns projects that have visits on the given reserve" do
      reserve1 = create(:reserve)
      reserve2 = create(:reserve)
      project1 = create(:project)
      project2 = create(:project)
      visit1 = create(:visit, reserve: reserve1, project: project1)
      visit2 = create(:visit, reserve: reserve2, project: project2)
      visit3 = create(:visit, reserve: reserve1, project: project1)

      results = Project.with_visits_at_reserve(reserve1)

      expect(results).to eq [project1]
    end
  end

  describe ".having_visit_end_date_after" do
    context "when 'date_var' is present" do
      it "returns projects that have visits with ends_at after the given 'date_var'" do
        project1 = create :project
        project2 = create :project
        create :visit, project: project1, starts_at: Time.current.yesterday, ends_at: Time.current.yesterday
        create :visit, project: project2, starts_at: Time.current.tomorrow, ends_at: Time.current.tomorrow

        results = Project.having_visit_end_date_after(Date.current)

        expect(results).to eq [project2]
      end
    end

    context "when 'date_var' is not present" do
      it "returns all projects" do
        project1 = create :project
        project2 = create :project
        create :visit, project: project1, starts_at: Time.current.yesterday, ends_at: Time.current.yesterday
        create :visit, project: project2, starts_at: Time.current.tomorrow, ends_at: Time.current.tomorrow

        results = Project.having_visit_end_date_after(nil)

        expect(results).to eq [project1, project2]
      end
    end
  end

  describe ".having_visit_start_date_before" do
    context "when 'date_var' is present" do
      it "returns projects that have visits with start_date before the given 'date_var'" do
        project1 = create :project
        project2 = create :project
        create :visit, project: project1, starts_at: Time.current.yesterday, ends_at: Time.current.yesterday
        create :visit, project: project2, starts_at: Time.current.tomorrow, ends_at: Time.current.tomorrow

        results = Project.having_visit_start_date_before(Date.current)

        expect(results).to eq [project1]
      end
    end

    context "when 'date_var' is not present" do
      it "returns all projects" do
        project1 = create :project
        project2 = create :project
        create :visit, project: project1, starts_at: Time.current.yesterday, ends_at: Time.current.yesterday
        create :visit, project: project2, starts_at: Time.current.tomorrow, ends_at: Time.current.tomorrow

        results = Project.having_visit_start_date_before(nil)

        expect(results).to eq [project1, project2]
      end
    end
  end

  describe ".sort_using" do
    it "calls the submitted_recent_first when supplied sort_option is 'submitted_recent_first'" do
      expect(Project).to receive(:sort_using).with("submitted_recent_first").and_return(Project.submitted_recent_first)

      Project.sort_using "submitted_recent_first"
    end

    it "calls the sort_by_project_title when supplied sort_option is 'project_title'" do
      expect(Project).to receive(:sort_using).with("project_title").and_return(Project.sort_by_project_title)

      Project.sort_using "project_title"
    end

    it "calls the sort_by_owner_last_name when supplied sort_option is 'owner_last_name'" do
      expect(Project).to receive(:sort_using).with("owner_last_name").and_return(Project.sort_by_owner_last_name)

      Project.sort_using "owner_last_name"
    end

    it "returns all when supplied sort_option is not present" do
      expect(Project).to receive(:sort_using).and_return(Project.all)

      Project.sort_using
    end
  end

  describe ".sort_by_project_title" do
    it "return projects sorted by title alphabetically" do
      project1 = create :project, title: "Observing woodpecker"
      project2 = create :project, title: "Swim with otters"
      project3 = create :project, title: "Capture red crabs"

      results = Project.sort_by_project_title

      expect(results).to eq [project3, project1, project2]
    end
  end

  describe ".sort_by_owner_last_name" do
    it "return projects sorted by owner last name alphabetically" do
      user1 = create :user, last_name: "Potter"
      user2 = create :user, last_name: "Weasley"
      user3 = create :user, last_name: "Granger"
      project1 = create :project, owner: user1
      project2 = create :project, owner: user2
      project3 = create :project, owner: user3

      results = Project.sort_by_owner_last_name

      expect(results).to eq [project3, project1, project2]
    end
  end

  describe ".searching_term" do
    context "when search_filter contain only numbers" do
      it "search project id" do
        project = create(:project)

        results = Project.searching_term(project.id.to_s)

        expect(results).to eq [project]
      end
    end

    context "when search_filter contain not only numbers" do
      let(:user) { create(:user, last_name: "Vil", first_name: "Cruella", email: "ceo@house.of.vil") }
      let(:project) do
        create :project,
          title: "Observing kangaroo mouse.",
          thesis_title: "Trap lots of animals, and experiment on them.",
          course_title: "Advanced Animals Trapping 401"
      end

      it "search project title" do
        results = Project.searching_term("kangaroo")

        expect(results).to eq [project]
      end

      it "search project thesis_title" do
        results = Project.searching_term("Trap lots of animals")

        expect(results).to eq [project]
      end

      it "search project course_title" do
        results = Project.searching_term("Trapping 401")

        expect(results).to eq [project]
      end

      it "search project team members last_name" do
        create(:project_team_membership, project: project, user: user)

        results = Project.searching_term("Vil")

        expect(results).to eq [project]
      end

      it "search project team members first_name" do
        create(:project_team_membership, project: project, user: user)

        results = Project.searching_term("Cruella")

        expect(results).to eq [project]
      end

      it "search project team members email" do
        create(:project_team_membership, project: project, user: user)

        results = Project.searching_term("@house.of.vil")

        expect(results).to eq [project]
      end
    end
  end
end
