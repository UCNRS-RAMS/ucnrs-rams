require "rails_helper"

RSpec.describe "new.html.erb" do
  describe "on any render" do
    it "includes steps (on step 1)" do
      assign(:presenter, ProjectFormPresenter.new(
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
      assign(:presenter, ProjectFormPresenter.new(
        user: :dummy,
        current_step: 1,
        project_type: :research,
      ))

      render template: "projects/new"

      doc = Capybara.string(rendered)
      expect(doc).to have_css("form div.research")
    end

    it "renders the class partial" do
      assign(:presenter, ProjectFormPresenter.new(
        user: :dummy,
        current_step: 1,
        project_type: :class,
      ))

      render template: "projects/new"

      doc = Capybara.string(rendered)
      expect(doc).to have_css("form div.class")
    end

    it "renders the meeting partial" do
      assign(:presenter, ProjectFormPresenter.new(
        user: :dummy,
        current_step: 1,
        project_type: :meeting,
      ))

      render template: "projects/new"

      doc = Capybara.string(rendered)
      expect(doc).to have_css("form div.meeting")
    end
  end

  describe "the submit button" do
    it "renders a button with the correct text for step 1" do
      assign(:presenter, ProjectFormPresenter.new(
        user: :dummy,
        current_step: 1,
      ))

      render template: "projects/new"

      doc = Capybara.string(rendered)
      expect(doc).to have_css("button[form='projects-new']", text: "Next: Team")
    end
  end

  describe "the project information modal" do
    include Devise::Test::ControllerHelpers

    it "displays a modal when a modal should be shown" do
      assign(:presenter, ProjectFormPresenter.new(
        user: :dummy,
        current_step: 1,
        show_modal: true,
      ))
      assign(:layout_presenter, LayoutPresenter.new(
        current_user: nil,
        current_reserve: nil,
        controller_path: nil,
        dashboard: nil
      ))

      render template: "projects/new", layout: "layouts/application"

      doc = Capybara.string(rendered)
      expect(doc).to have_css(".modal-content.project")
    end

    it "does not display a modal when a modal should not be shown" do
      assign(:presenter, ProjectFormPresenter.new(
        user: :dummy,
        current_step: 1,
        show_modal: false,
      ))
      assign(:layout_presenter, LayoutPresenter.new(
        current_user: nil,
        current_reserve: nil,
        controller_path: nil,
        dashboard: nil
      ))

      render template: "projects/new", layout: "layouts/application"

      doc = Capybara.string(rendered)
      expect(doc).to have_no_css(".modal-content.project")
    end
  end
end
