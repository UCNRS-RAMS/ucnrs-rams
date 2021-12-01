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

    it "renders the class partial" do
      assign(:presenter, ProjectsNewPresenter.new(
        user: :dummy,
        current_step: 1,
        project_type: :class,
      ))

      render template: "projects/new"

      doc = Capybara.string(rendered)
      expect(doc).to have_css("form section.class")
    end

    it "renders the meeting partial" do
      assign(:presenter, ProjectsNewPresenter.new(
        user: :dummy,
        current_step: 1,
        project_type: :meeting,
      ))

      render template: "projects/new"

      doc = Capybara.string(rendered)
      expect(doc).to have_css("form section.meeting")
    end
  end

  describe "the submit button" do
    it "renders a button with the correct text for step 1" do
      assign(:presenter, ProjectsNewPresenter.new(
        user: :dummy,
        current_step: 1,
      ))

      render template: "projects/new"

      doc = Capybara.string(rendered)
      expect(doc).to have_css("button[form='projects-new']", text: "Next: Team")
    end
  end
 end
