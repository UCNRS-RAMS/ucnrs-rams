require "rails_helper"

RSpec.describe "new.html.erb" do
  describe "on any render" do
    it "includes steps (on step 1)" do
      assign(:presenter, ProjectsNewPresenter.new(
        user: :dummy,
        current_step: 1,
      ))

      render template: "projects/new"

      doc = Capybara.string(rendered)
      expect(doc).to have_css("section.progress-steps")
      expect(doc).to have_css(".progress-steps li.active:nth-child(1)")
    end
  end

  describe "when project_type is defined" do
    it "renders the research partial" do
      assign(:presenter, ProjectsNewPresenter.new(
        user: :dummy,
        current_step: 1,
        project_type: :research,
      ))

      render template: "projects/new"

      doc = Capybara.string(rendered)
      expect(doc).to have_css("form section.research")
    end

    it "renders the university_class partial" do
      assign(:presenter, ProjectsNewPresenter.new(
        user: :dummy,
        current_step: 1,
        project_type: :university_class,
      ))

      render template: "projects/new"

      doc = Capybara.string(rendered)
      expect(doc).to have_css("form section.university_class")
    end

    it "renders the meeting_or_conference partial" do
      assign(:presenter, ProjectsNewPresenter.new(
        user: :dummy,
        current_step: 1,
        project_type: :meeting_or_conference,
      ))

      render template: "projects/new"

      doc = Capybara.string(rendered)
      expect(doc).to have_css("form section.meeting_or_conference")
    end
  end
end
