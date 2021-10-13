require "rails_helper"

RSpec.describe Project, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:reserve) }
    it { is_expected.to belong_to(:owner).class_name("User").with_foreign_key(:user_id) }
    it { is_expected.to belong_to(:applicant).class_name("User") }
    it { is_expected.to have_many(:visits) }
    it { is_expected.to have_many(:team_memberships).class_name("ProjectTeamMembership") }
    it { is_expected.to have_many(:team_members).class_name("User") }
  end

  it do 
    is_expected.to define_enum_for(:status)
      .with_values(
        open: "Open",
        closed: "Closed",
        incomplete: "Incomplete",
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
    it "returns all projects that are associated with a given user and are labeled as active" do
      first_user = create(:user)
      second_user = create(:user)
      first_project = create(:project)
      second_project = create(:project)
      third_project = create(:project)
      create(:project_team_membership, project: first_project, user: first_user, active: false)
      create(:project_team_membership, project: second_project, user: second_user, active: true)
      create(:project_team_membership, project: third_project, user: first_user, active: true)

      results = Project.with_active_team_member(first_user)

      expect(results).to match_array [third_project]
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
end
