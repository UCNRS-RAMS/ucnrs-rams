require "rails_helper"

RSpec.describe "app/views/shared/projects/team_memberships/_next_step_button.html.erb" do
  it "renders a button that links to the project details page" do
    project = build_stubbed(:project)
    presenter = OpenStruct.new(project: project)

    render partial: "shared/projects/team_memberships/next_step_button", locals: { presenter: presenter, project_link: project_questions_path(project)}

    doc = Capybara.string(rendered)
    expect(doc).to have_css("form[action='/projects/#{project.id}/questions'] button", text: "Next: Permits")
  end
end
