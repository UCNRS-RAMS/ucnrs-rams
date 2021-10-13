require "rails_helper"

RSpec.describe ProjectsIndexPresenter do
  describe "#projects" do
    it "only presents projects where the user is deemed active" do
      user = create(:user)
      first_active_project = create(:project, created_at: DateTime.current - 2.days)
      second_active_project = create(:project, created_at: DateTime.current)
      inactive_project = create(:project, created_at: DateTime.current)
      create(:project_team_member, user: user, project: first_active_project, active: true)
      create(:project_team_member, user: user, project: second_active_project, active: true)
      create(:project_team_member, user: user, project: inactive_project, active: false)
      presenter = ProjectsIndexPresenter.new(user)

      projects = presenter.projects

      expect(projects.length).to eq 2
      expect(projects.map(&:id)).to eq [
        second_active_project.id,
        first_active_project.id,
      ]
    end

    it "presents the user's projects ordered as recent first" do
      user = create(:user)
      first_project = create(:project, created_at: DateTime.current - 2.days)
      second_project = create(:project, created_at: DateTime.current)
      create(:project_team_member, user: user, project: first_project)
      create(:project_team_member, user: user, project: second_project)
      presenter = ProjectsIndexPresenter.new(user)

      projects = presenter.projects

      expect(projects.length).to eq 2
      expect(projects.map(&:id)).to eq [
        second_project.id,
        first_project.id,
      ]
    end

    it "presents a maxiumum of 10 projects" do
      user = create(:user)
      presenter = ProjectsIndexPresenter.new(user)
      create_list(:project_team_member, 11, user: user)

      projects = presenter.projects

      expect(projects.length).to eq 10
    end
  end
end
