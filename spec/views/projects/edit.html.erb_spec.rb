require "rails_helper"

RSpec.describe "edit.html.erb" do
  describe "on any render" do
    it "includes steps (on step 1)" do
      form = ProjectForm.new(params: { id: build_stubbed(:project).id })
      assign(:presenter, ProjectFormPresenter.new(
        user: :dummy,
        current_step: 1,
        form: form,
      ))

      render template: "projects/edit"

      doc = Capybara.string(rendered)
      expect(doc).to have_css("section.progress-steps")
      expect(doc).to have_css(".progress-steps li.active:nth-child(1)")
    end
  end

  describe "when project_type is defined" do
    it "renders the research partial" do
      form = ProjectForm.new(params: { id: build_stubbed(:project).id })
      assign(:presenter, ProjectFormPresenter.new(
        user: :dummy,
        current_step: 1,
        project_type: :research,
        form: form,
      ))

      render template: "projects/edit"

      doc = Capybara.string(rendered)
      expect(doc).to have_css("form section.research")
    end

    it "renders the class partial" do
      form = ProjectForm.new(params: { id: build_stubbed(:project).id })
      assign(:presenter, ProjectFormPresenter.new(
        user: :dummy,
        current_step: 1,
        project_type: :class,
        form: form,
      ))

      render template: "projects/edit"

      doc = Capybara.string(rendered)
      expect(doc).to have_css("form section.class")
    end

    it "renders the meeting partial" do
      form = ProjectForm.new(params: { id: build_stubbed(:project).id })
      assign(:presenter, ProjectFormPresenter.new(
        user: :dummy,
        current_step: 1,
        project_type: :meeting,
        form: form,
      ))

      render template: "projects/edit"

      doc = Capybara.string(rendered)
      expect(doc).to have_css("form section.meeting")
    end
  end

  describe "the submit button" do
    it "renders a button with the correct text for step 1" do
      form = ProjectForm.new(params: { id: build_stubbed(:project).id })
      assign(:presenter, ProjectFormPresenter.new(
        user: :dummy,
        current_step: 1,
        form: form,
      ))

      render template: "projects/edit"

      doc = Capybara.string(rendered)
      expect(doc).to have_css("button[form='projects-edit']", text: "Next: Team")
    end
  end
 end

