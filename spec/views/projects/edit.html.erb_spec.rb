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

    describe "editing project type" do
      it "displays the project type fields if the project's type can be edited" do
        project = create(:project, status: "incomplete")
        form = ProjectForm.new(params: { id: project.id })
        assign(:presenter, ProjectFormPresenter.new(
          user: :dummy,
          current_step: 1,
          form: form,
        ))

        render template: "projects/edit"

        doc = Capybara.string(rendered)
        expect(doc).to have_field("project-type-research", type: "radio")
        expect(doc).to have_field("project-type-class", type: "radio")
        expect(doc).to have_field("project-type-meeting", type: "radio")
      end

      it "displays the project type and description if the project's type cannot be edited" do
        project = create(
          :project,
          status: "open",
          project_type: "research",
        )
        form = ProjectForm.new(params: { id: project.id })
        assign(:presenter, ProjectFormPresenter.new(
          user: :dummy,
          current_step: 1,
          form: form,
        ))

        render template: "projects/edit"

        doc = Capybara.string(rendered)
        expect(doc).to have_css(".uneditable-project-type h3", text: "Research")
        expect(doc).to have_css(".uneditable-project-type p", text: "Field or lab-based research in any discipline")
      end
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

