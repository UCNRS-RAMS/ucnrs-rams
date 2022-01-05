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
  end
end
