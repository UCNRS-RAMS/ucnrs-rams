require "rails_helper"

RSpec.describe Manager::Visits::ProjectsPresenter do
  describe "#projects" do
    it "is the projects where the project type matches the supplied type, the user has an active membership" do
      user = create(:user)
      first_active_project = create(:project, project_type: "research")
      second_active_project = create(:project, project_type: "research")
      inactive_project = create(:project, project_type: "research")
      create(:project_team_membership, user: user, project: first_active_project, active: true, can_add_visit: true)
      create(:project_team_membership, user: user, project: second_active_project, active: true, can_add_visit: false)
      create(:project_team_membership, user: user, project: inactive_project, active: false, can_add_visit: true)
      presenter = Manager::Visits::ProjectsPresenter.new(user: user, project_type: "research", project_id: nil)

      projects = presenter.projects

      expect(projects.length).to eq 2
      expect(projects.map(&:id)).to match_array [second_active_project.id, first_active_project.id]
    end

    it "orders the projects by project type [Research, Class, Conference, Public Use]" do
      user = create(:user)
      project_public_use = create(:project, project_type: :public_use)
      project_class = create(:project, project_type: :class)
      project_research = create(:project, project_type: :research)
      project_conference = create(:project, project_type: :meeting)
      create(:project_team_membership, project: project_public_use, user: user, active: true, can_add_visit: true)
      create(:project_team_membership, project: project_class, user: user, active: true, can_add_visit: true)
      create(:project_team_membership, project: project_research, user: user, active: true, can_add_visit: true)
      create(:project_team_membership, project: project_conference, user: user, active: true, can_add_visit: true)
      presenter = Manager::Visits::ProjectsPresenter.new(user: user, project_type: "university_class", project_id: nil)

      projects = presenter.projects

      expect(projects.map(&:id)).to eq [project_research.id, project_class.id, project_conference.id, project_public_use.id]
    end

    it "orders the projects by project id" do
      user = create(:user)
      project_1 = create(:project)
      project_2 = create(:project)
      project_3 = create(:project)
      project_4 = create(:project)
      create(:project_team_membership, project: project_1, user: user, active: true, can_add_visit: true)
      create(:project_team_membership, project: project_2, user: user, active: true, can_add_visit: true)
      create(:project_team_membership, project: project_3, user: user, active: true, can_add_visit: true)
      create(:project_team_membership, project: project_4, user: user, active: true, can_add_visit: true)
      presenter = Manager::Visits::ProjectsPresenter.new(user: user, project_type: "university_class", project_id: nil)

      projects = presenter.projects

      expect(projects.map(&:id)).to eq [project_4.id, project_3.id, project_2.id, project_1.id]
    end

    it "orders the projects by project type first then by project id" do
      user = create(:user)
      project_research_1 = create(:project, project_type: :research)
      project_research_2 = create(:project, project_type: :research)
      project_class_1 = create(:project, project_type: :class)
      project_class_2 = create(:project, project_type: :class)
      create(:project_team_membership, project: project_class_1, user: user, active: true, can_add_visit: true)
      create(:project_team_membership, project: project_class_2, user: user, active: true, can_add_visit: true)
      create(:project_team_membership, project: project_research_1, user: user, active: true, can_add_visit: true)
      create(:project_team_membership, project: project_research_2, user: user, active: true, can_add_visit: true)
      presenter = Manager::Visits::ProjectsPresenter.new(user: user, project_type: "university_class", project_id: nil)

      projects = presenter.projects

      expect(projects.map(&:id)).to eq [project_research_2.id, project_research_1.id, project_class_2.id, project_class_1.id]
    end
  end
end
