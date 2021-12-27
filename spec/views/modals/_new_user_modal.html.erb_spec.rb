require "rails_helper"

RSpec.describe "modals/_new_user.html.erb", type: :view do
  it "renders a turbo-frame modal" do
    presenter = Projects::UserNewPresenter.new(
      form: UserForm.new,
      project: build_stubbed(:project),
    )

    render partial: "modals/new_user", locals: { presenter: presenter }

    doc = Capybara.string(rendered)
    expect(doc).to have_css("turbo-frame#modal-content")
  end

  it "includes an autocomplete form for institution name" do
    presenter = Projects::UserNewPresenter.new(
      form: UserForm.new,
      project: build_stubbed(:project),
    )

    render partial: "modals/new_user", locals: { presenter: presenter }

    doc = Capybara.string(rendered)
    expect(doc).to have_css("div.autocomplete[data-controller='autocomplete'][data-autocomplete-url-value='/institutions']")
    expect(doc).to have_css("div.autocomplete-results-container > .autocomplete-results[data-autocomplete-target='results']")
    expect(doc).to have_css("input[data-autocomplete-target='hidden']", visible: false)
    expect(doc).to have_css("input[data-autocomplete-target='input']")
  end

  it "renders a form with the right fields for a new user" do
    project = build_stubbed(:project)
    presenter = Projects::UserNewPresenter.new(
      form: UserForm.new,
      project: project,
    )

    render partial: "modals/new_user", locals: { presenter: presenter }

    doc = Capybara.string(rendered)
    expect(doc).to have_css("form[action='/projects/#{project.id}/users']")
    expect(doc).to have_field("First name")
    expect(doc).to have_field("Last name")
    expect(doc).to have_field("Email")
    expect(doc).to have_field("user[institution_id]", type: "hidden")
    expect(doc).to have_field("Institution name")
    expect(doc).to have_select("User role")
    expect(doc).to have_select("Project role")
  end
end
