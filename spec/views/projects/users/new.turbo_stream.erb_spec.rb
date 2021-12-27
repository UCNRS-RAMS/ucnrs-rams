require "rails_helper"

RSpec.describe "projects/users/new.turbo_stream.erb", type: :view do
  it "renders an empty modal" do
    project = create(:project)
    form = UserForm.new
    @presenter = Projects::UserNewPresenter.new(form: form)

    controller.request.path_parameters[:project_id] = project.id
    render template: "projects/users/new",
      presenter: @presenter,
      formats: [:turbo_stream]

    expect(rendered).to include(
      '<turbo-stream action="replace" target="modal-content"'
    )
    expect(rendered).to include( '<turbo-frame id="modal-content"')
  end
end
