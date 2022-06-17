require "rails_helper"

RSpec.describe "app/views/shared/projects/team_memberships/_finish_button.html.erb" do
  it "renders a button that links to the project summary page" do
    project = build_stubbed(:project)
    presenter = OpenStruct.new(project: project)

    render partial: "shared/projects/team_memberships/finish_button", locals: { presenter: presenter }

    doc = Capybara.string(rendered)
    expect(doc).to have_css("form[action='/projects/#{project.id}'] button", text: "Save Memberships")
  end
end
