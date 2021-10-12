require "rails_helper"

RSpec.describe ProjectsIndexPresenter do
  describe "#projects" do
    it "presents the user's projects in order" do
      user = create(:user)
      first_project = create(:project, owner: user)
      second_project = create(:project, owner: user)
      third_project = create(:project, owner: user)
      fourth_project = create(:project)
      presenter = ProjectsIndexPresenter.new(user)

      projects = presenter.projects

      expect(projects.length).to eq 3
      expect(projects.map(&:id)).to eq [
        first_project.id,
        second_project.id,
        third_project.id,
      ]
    end
  end
end
