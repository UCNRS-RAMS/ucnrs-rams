require "rails_helper"

RSpec.describe "_autocomplete_results.html.erb" do
  it "generates an li with the label, value, and text" do
    presenter = UserPresenter.new(
      build(
        :user,
        id: 42,
        first_name: "Person",
        last_name: "McGee",
        email: "1234@count.test",
        institution: build(:institution, name: "Fly-by-night U."),
      )
    )

    render partial: "users/autocomplete_result", locals: { autocomplete_result: presenter }

    doc = Capybara.string(rendered)
    expect(doc).to have_css("li[data-autocomplete-value='42']")
    expect(doc).to have_css("li[data-autocomplete-label='Person McGee']")
    expect(doc).to have_css("li", text: "Person McGee - Fly-by-night U. - 1xx4@count.test")
  end
end
