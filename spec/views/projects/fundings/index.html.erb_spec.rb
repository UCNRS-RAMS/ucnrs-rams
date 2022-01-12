require "rails_helper"

RSpec.describe "app/views/projects/fundings/index.html.erb" do
  describe "on any render" do
    it "includes steps (on step 4)" do
      assign(:presenter, Projects::FundingsIndexPresenter.new(
        project: :dummy,
        current_step: 4,
      ))

      render template: "projects/fundings/index"

      doc = Capybara.string(rendered)
      expect(doc).to have_css("section.progress-steps")
      expect(doc).to have_css(".progress-steps li.active:nth-child(4)")
    end
  end
end
