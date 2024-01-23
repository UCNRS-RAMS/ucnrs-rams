require "rails_helper"

RSpec.describe "projects/users/new.html.erb", type: :view do
  it "renders a turbo-frame modal" do
    create(:country, name: "United States")
    create(:state, name: "California")
    assign(:presenter, Projects::UserNewPresenter.new(
        form: UserForm.new,
        project: build_stubbed(:project)
      )
    )

    render template: "projects/users/new"

    doc = Capybara.string(rendered)
    expect(doc).to have_css("turbo-frame#modal-content")
  end
end
