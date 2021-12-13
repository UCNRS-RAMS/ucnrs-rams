require "rails_helper"

RSpec.describe "index.html.erb" do
  describe "on any render" do
    it "includes steps (on step 2)" do
      assign(:presenter, Projects::TeamMembershipsIndexPresenter.new(
        user: :dummy,
        current_step: 2,
        project: build(:project),
      ))

      render template: "projects/team_memberships/index"

      doc = Capybara.string(rendered)
      expect(doc).to have_css("section.progress-steps")
      expect(doc).to have_css(".progress-steps li.active:nth-child(2)")
    end

    it "displays a form to add a project team member" do
      assign(:presenter, Projects::TeamMembershipsIndexPresenter.new(
        user: :dummy,
        current_step: 2,
        project: build(:project),
      ))

      render template: "projects/team_memberships/index"

      doc = Capybara.string(rendered)
      expect(doc).to have_css("form")
      expect(doc).to have_field("Full name", type: "text")
      expect(doc).to have_field("Project role", type: "select")
    end

    it "includes markup for autocomplete on the user field" do
      assign(:presenter, Projects::TeamMembershipsIndexPresenter.new(
        user: :dummy,
        current_step: 2,
        project: build(:project),
      ))

      render template: "projects/team_memberships/index"

      doc = Capybara.string(rendered)
      field = doc.find(".field.autocomplete[data-controller='autocomplete']")
      expect(field["data-autocomplete-url-value"]).to eq "/users"
      expect(field).to have_css("input[data-autocomplete-target='input']")
      expect(field).to have_css(".autocomplete-results-container .autocomplete-results[data-autocomplete-target='results']")
    end
  end
end
