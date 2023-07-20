require "rails_helper"

RSpec.describe "modals/edit_project_funding.html.erb", type: :view do
  it "renders a turbo-frame modal" do
    form = ProjectFundingForm.new(
      params: create(:funding).attributes
    )
    presenter = Projects::FundingEditPresenter.new(form: form)

    render partial: "modals/edit_project_funding", locals: { presenter: presenter }

    doc = Capybara.string(rendered)
    expect(doc).to have_css("turbo-frame#modal-content")
  end

  it "renders a form with the right fields for a membership" do
    form = ProjectFundingForm.new(
      params: create(:funding).attributes
    )
    presenter = Projects::FundingEditPresenter.new(form: form)

    render partial: "modals/edit_project_funding", locals: { presenter: presenter }

    doc = Capybara.string(rendered)
    expect(doc).to have_field("Official Grant Title", type: "text")
    expect(doc).to have_field("Funding Opportunity Number", type: "text")
    expect(doc).to have_field("Grant Number", type: "text")
    expect(doc).to have_field("Principal Investigators", type: "textarea")
    expect(doc).to have_field("Co-Principal Investigators", type: "textarea")
    expect(doc).to have_field("Funding Agency", type: "select")
    expect(doc).to have_field("Award Amount", type: "text")
    expect(doc).to have_field("Start Date", type: "date")
    expect(doc).to have_field("End Date", type: "date")
    expect(doc).to have_link("Cancel")
    expect(doc).to have_button("Save")
  end
end
