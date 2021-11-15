require "rails_helper"

RSpec.describe Visits::ProjectsPresenter do
  describe "#projects" do
    it "is the projects where the project type matches the supplied type, the user has an active membership, and has the ability to add visits" do
      user = create(:user)
      first_active_project = create(:project, project_type: "research")
      second_active_project = create(:project, project_type: "research")
      inactive_project = create(:project, project_type: "research")
      create(:project_team_membership, user: user, project: first_active_project, active: true, can_add_visit: true)
      create(:project_team_membership, user: user, project: second_active_project, active: true, can_add_visit: false)
      create(:project_team_membership, user: user, project: inactive_project, active: false, can_add_visit: true)
      presenter = Visits::ProjectsPresenter.new(user: user, project_type: "research", project_id: nil)

      projects = presenter.projects

      expect(projects.length).to eq 2
      expect(projects.map(&:id)).to match_array [-1, first_active_project.id]
    end

    it "orders the projects alphabetically by title" do
      user = create(:user)
      project_c = create(:project, title: "Project C", project_type: "Class")
      project_a = create(:project, title: "Project A", project_type: "Class")
      project_b = create(:project, title: "Project B", project_type: "Class")
      create(:project_team_membership, project: project_c, user: user, active: true, can_add_visit: true)
      create(:project_team_membership, project: project_a, user: user, active: true, can_add_visit: true)
      create(:project_team_membership, project: project_b, user: user, active: true, can_add_visit: true)
      presenter = Visits::ProjectsPresenter.new(user: user, project_type: "university_class", project_id: nil)

      projects = presenter.projects

      expect(projects.map(&:title)).to eq ["", "Project A", "Project B", "Project C"]
    end

    it "is the alphabetized public projects, independent of the user" do
      user = create(:user)
      public_project_b = create(:project, title: "Public Project B", project_type: :public_use)
      public_project_a = create(:project, title: "Public Project A", project_type: :public_use)
      research_project = create(:project, project_type: :research)
      presenter = Visits::ProjectsPresenter.new(user: user, project_type: "public_use", project_id: nil)

      projects = presenter.projects

      expect(projects.length).to eq 3
      expect(projects.map(&:id)).to match_array [Project.blank.id, public_project_a.id, public_project_b.id]
    end
  end
end
