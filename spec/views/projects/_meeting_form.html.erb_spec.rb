require "rails_helper"

RSpec.describe "app/views/projects/_meeting_form.html.erb", type: :view do
  it "has the required fields in the 'Details' section" do
    presenter = ProjectsNewPresenter.new(
      user: :fake_user,
      current_step: 1,
    )

    FakeForm.fields_for(ProjectForm.new) do |form|
      render partial: "projects/meeting_form",
        locals: { presenter: presenter, form: form }
    end

    doc = Capybara.string(rendered)
    expect(doc).to have_field("Event Title", type: "text")
    expect(doc).to have_field("Event Description", type: "textarea")
  end

  it "has start and end date fields" do
    presenter = ProjectsNewPresenter.new(
      user: :fake_user,
      current_step: 1,
    )

    FakeForm.fields_for(ProjectForm.new) do |form|
      render partial: "projects/meeting_form",
        locals: { presenter: presenter, form: form }
    end

    doc = Capybara.string(rendered)
    expect(doc).to have_field("Start Date", type: "date")
    expect(doc).to have_field("End Date", type: "date")
  end

  it "has the required fields in the 'Disciplines' section" do
    presenter = ProjectsNewPresenter.new(
      user: :fake_user,
      current_step: 1,
    )

    FakeForm.fields_for(ProjectForm.new) do |form|
      render partial: "projects/meeting_form",
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
end
