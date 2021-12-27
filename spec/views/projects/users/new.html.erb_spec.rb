require "rails_helper"

RSpec.describe "projects/users/new.html.erb", type: :view do
  it "renders a turbo-frame modal" do
    project = create(:project)
    form = UserForm.new
    assign(:presenter, Projects::UserNewPresenter.new(form: form))

    controller.request.path_parameters[:project_id] = project.id
    render template: "projects/users/new"

    doc = Capybara.string(rendered)
    expect(doc).to have_css("turbo-frame#modal-content")
  end
end
