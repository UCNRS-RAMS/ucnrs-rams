require "rails_helper"

RSpec.describe "projects/users/new.turbo_stream.erb", type: :view do
  it "renders an empty modal" do
    create(:country, name: "United States")
    create(:state, name: "California")
    @presenter = Projects::UserNewPresenter.new(
      form: UserForm.new,
      project: build_stubbed(:project)
    )

    render template: "projects/users/new",
      presenter: @presenter,
      formats: [:turbo_stream]

    expect(rendered).to include(
      '<turbo-stream action="replace" target="modal-content"'
    )
    expect(rendered).to include( '<turbo-frame id="modal-content"')
  end
end
