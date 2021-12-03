require "rails_helper"

RSpec.describe "edit.html.erb" do
  describe "on any render" do
    it "includes steps (on step 2)" do
      assign(:presenter, Projects::TeamsEditPresenter.new(
        user: :dummy,
        current_step: 2,
      ))

      render template: "projects/teams/edit"

      doc = Capybara.string(rendered)
      expect(doc).to have_css("section.progress-steps")
      expect(doc).to have_css(".progress-steps li.active:nth-child(2)")
    end
  end
 end
