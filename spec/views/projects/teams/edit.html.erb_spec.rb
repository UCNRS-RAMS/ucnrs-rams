require "rails_helper"

RSpec.describe "edit.html.erb" do
  describe "on any render" do
    it "includes steps (on step 2)" do
      assign(:presenter, Projects::TeamsEditPresenter.new(
        user: :dummy,
        current_step: 2,
        project: build(:project),
      ))

      render template: "projects/teams/edit"

      doc = Capybara.string(rendered)
      expect(doc).to have_css("section.progress-steps")
      expect(doc).to have_css(".progress-steps li.active:nth-child(2)")
    end

    it "displays a form to add a project team member" do
      assign(:presenter, Projects::TeamsEditPresenter.new(
        user: :dummy,
        current_step: 2,
        project: build(:project),
      ))

      render template: "projects/teams/edit"

      doc = Capybara.string(rendered)
      expect(doc).to have_css("form")
      expect(doc).to have_field("Full name", type: "text")
      expect(doc).to have_field("Project role", type: "select")
    end
  end
end
