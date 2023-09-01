require "rails_helper"

RSpec.describe "app/views/projects/_meeting_form.html.erb", type: :view do
  it "has the required fields in the 'Details' section" do
    presenter = ProjectFormPresenter.new(
      user: :fake_user,
      current_step: 1,
    )

    FakeForm.fields_for(ProjectForm.new) do |form|
      render partial: "shared/projects/meeting_form",
        locals: { presenter: presenter, form: form }
    end

    doc = Capybara.string(rendered)
    expect(doc).to have_field("Event Title", type: "text")
    expect(doc).to have_field("Event Description", type: "textarea")
  end

  it "has start and end date fields" do
    presenter = ProjectFormPresenter.new(
      user: :fake_user,
      current_step: 1,
    )

    FakeForm.fields_for(ProjectForm.new) do |form|
      render partial: "shared/projects/meeting_form",
        locals: { presenter: presenter, form: form }
    end

    doc = Capybara.string(rendered)
    expect(doc).to have_field("Start Date", type: "date")
    expect(doc).to have_field("End Date", type: "date")
  end

  it "has the required fields in the 'Disciplines' section" do
    presenter = ProjectFormPresenter.new(
      user: :fake_user,
      current_step: 1,
    )

    FakeForm.fields_for(ProjectForm.new) do |form|
      render partial: "shared/projects/meeting_form",
        locals: { presenter: presenter, form: form }
    end

    doc = Capybara.string(rendered)
    expect(doc).to have_field("Agriculture", type: "radio")
    expect(doc).to have_field("Arts/Humanities", type: "radio")
    expect(doc).to have_field("Medical, Health & Safety", type: "radio")
    expect(doc).to have_field("Biology", type: "radio")
    expect(doc).to have_field("Earth Sciences", type: "radio")
    expect(doc).to have_field("Education", type: "radio")
    expect(doc).to have_field("Engineering/Computer Science", type: "radio")
    expect(doc).to have_field("Environmental Science/Natural Resources", type: "radio")
    expect(doc).to have_field("Physical Sciences", type: "radio")
    expect(doc).to have_field("Social Sciences", type: "radio")
    expect(doc).to have_field("Veterinary Medicine", type: "radio")
    expect(doc).to have_field("Other", type: "radio")
    expect(doc).to have_field("project_discipline_other", type: "text")
  end

  context "when displaying errors" do
    it "displays errors on all validated fields" do
      user = User.new
      project_form = ProjectForm.new(params: { project_type: :meeting }, user: user)
      project_form.validate
      presenter = ProjectFormPresenter.new(
        user: user,
        current_step: 1,
        project_type: :meeting,
        form: project_form,
      )

      FakeForm.fields_for(project_form) do |form|
        render partial: "shared/projects/meeting_form",
          locals: { presenter: presenter, form: form }
      end

      doc = Capybara.string(rendered)
      expect(doc).to display_error(I18n.t("activerecord.errors.messages.blank"))
        .for_field("Event Title")
      expect(doc).to display_error(I18n.t("activerecord.errors.messages.blank"))
        .for_field("Event Description")
    end
  end
end
