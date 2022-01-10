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
      it { is_expected.to validate_presence_of(:method_study_area) }
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
      it { is_expected.to validate_presence_of(:discipline) }
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

      results = Project.ordered_by_visit_date

      expect(results.map(&:title)).to eq [
        "P3",
        "P5",
        "P6",
        "P2",
        "P4",
        "P1",
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
end
