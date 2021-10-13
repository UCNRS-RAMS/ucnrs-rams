require "rails_helper"

RSpec.describe Project, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:reserve) }
    it { is_expected.to belong_to(:owner).class_name("User").with_foreign_key(:user_id) }
    it { is_expected.to belong_to(:applicant).class_name("User") }
    it { is_expected.to have_many(:visits) }
    it { is_expected.to have_many(:team_members).class_name("ProjectTeamMember") }
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
      create(:project_team_member, project: first_project, user: first_user, active: false)
      create(:project_team_member, project: second_project, user: second_user, active: true)
      create(:project_team_member, project: third_project, user: first_user, active: true)

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
