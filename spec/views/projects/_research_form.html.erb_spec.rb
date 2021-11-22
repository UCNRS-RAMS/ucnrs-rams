require "rails_helper"

RSpec.describe "app/views/projects/_research_form.html.erb", type: :view do
  it "has the required fields in the 'Details' section" do
    presenter = ProjectsNewPresenter.new(
      user: :fake_user,
      current_step: 1,
    )

    FakeForm.fields_for(ProjectForm.new) do |form|
      render partial: "projects/research_form",
        locals: { presenter: presenter, form: form }
    end

    doc = Capybara.string(rendered)
    expect(doc).to have_field("Project or Event Title", type: "text")
    expect(doc).to have_field("Thesis Title", type: "text")
    expect(doc).to have_field("Project Abstract", type: "textarea")
  end
end
