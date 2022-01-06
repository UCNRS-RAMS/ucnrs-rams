require "rails_helper"

RSpec.describe "app/views/projects/permits/index.html.erb" do
  describe "on any render" do
    it "includes steps (on step 3)" do
      assign(:presenter, Projects::PermitsIndexPresenter.new(
        project: build(:project),
        current_step: 3,
      ))

      render template: "projects/permits/index"

      doc = Capybara.string(rendered)
      expect(doc).to have_css("section.progress-steps")
      expect(doc).to have_css(".progress-steps li.active:nth-child(3)")
    end

    it "displays a message if there are no permits to show" do
      _unapplicable_permit = build(:permit, involves_mammals: false)
      assign(:presenter, Projects::PermitsIndexPresenter.new(
        project: build(:project, involves_mammals: true),
        current_step: 3,
      ))

      render template: "projects/permits/index"

      doc = Capybara.string(rendered)
      expect(doc).to have_content("There are no necessary permit questions for this project at this time.")
    end
  end
end
