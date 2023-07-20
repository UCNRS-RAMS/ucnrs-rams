require "rails_helper"

RSpec.describe "app/views/projects/fundings/index.html.erb" do
  describe "on any render" do
    it "includes steps (on step 4)" do
      project = build_stubbed(:project)
      assign(:presenter, Projects::FundingsIndexPresenter.new(
        project: project,
        current_step: 4,
      ))

      render template: "projects/fundings/index"

      doc = Capybara.string(rendered)
      expect(doc).to have_css("section.progress-steps")
      expect(doc).to have_css(".progress-steps li.active:nth-child(4)")
    end

    it "displays a form to add funding" do
      project = build_stubbed(:project)
      assign(:presenter, Projects::FundingsIndexPresenter.new(
        current_step: 4,
        project: project,
      ))

      render template: "projects/fundings/index"

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
      expect(doc).to have_button("Add Funding Information")
    end

    it "displays errors that are on the form object" do
      project = create(:project)
      form = ProjectFundingForm.new(
        project: project,
        params: {
          title: "",
          principal_investigators: "",
          co_principal_investigators: nil,
          start_date: Date.new(2022, 1, 2),
          end_date: Date.new(2022, 1, 1),
          sponsor: :other,
          sponsor_other: "",
          award_amount: "",
          grant_number: "",
          funding_opportunity_number: "",
        }
      )
      assign(:presenter, Projects::FundingsIndexPresenter.new(
        current_step: 4,
        project: project,
        form: form
      ))
      form.validate

      render template: "projects/fundings/index"

      doc = Capybara.string(rendered)
      expect(doc).to display_error("can't be blank").for_field("Title")
      expect(doc).to display_error("can't be blank").for_field("Principal Investigators")
      expect(doc).to display_error("must be after Start date").for_field("End")
      expect(doc).to have_css("[data-value-projection-projected-value='other'] input[name='funding[sponsor_other]']")
      expect(doc).to display_error("can't be blank").for_field("Enter Funding Agency Name")
    end

    it "renders a button as a form with the correct text for step 4" do
      project = create(:project)
      assign(:presenter, Projects::FundingsIndexPresenter.new(
        current_step: 4,
        project: project,
      ))

      render template: "projects/fundings/index"

      doc = Capybara.string(rendered)
      expect(doc).to have_css(
        ".controls form[action='/projects/#{project.id}/complete']",
        text: "Save Project & Submit",
      )
    end

    it "renders a link to go back to the previous step (permits)" do
      project = build_stubbed(:project)
      assign(:presenter, Projects::FundingsIndexPresenter.new(
        current_step: 4,
        project: project,
      ))

      render template: "projects/fundings/index"

      doc = Capybara.string(rendered)
      expect(doc).to have_css(".controls a[href='/projects/#{project.id}/questions']", text: "Go Back")
    end
  end
end
