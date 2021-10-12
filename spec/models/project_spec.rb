require "rails_helper"

RSpec.describe Project, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:reserve) }
    it { is_expected.to belong_to(:owner).class_name("User").with_foreign_key(:user_id) }
    it { is_expected.to belong_to(:applicant).class_name("User") }
    it { is_expected.to have_many(:visits) }
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
