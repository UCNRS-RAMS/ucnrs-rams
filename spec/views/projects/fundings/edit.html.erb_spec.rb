require "rails_helper"

RSpec.describe "projects/fundings/edit.html.erb", type: :view do
  it "renders a turbo-frame modal" do
    form = ProjectFundingForm.new(
      params: create(:funding).attributes
    )
    assign(:presenter, Projects::FundingEditPresenter.new(form: form))

    render template: "projects/fundings/edit"

    doc = Capybara.string(rendered)
    expect(doc).to have_css("turbo-frame#modal-content")
  end

  it "has a link to destroy a funding source" do
    form = ProjectFundingForm.new(
      params: create(:funding).attributes
    )
    assign(:presenter, Projects::FundingEditPresenter.new(form: form))

    render template: "projects/fundings/edit"

    doc = Capybara.string(rendered)
    expect(doc).to have_css("a[data-method='delete']")
  end
end
