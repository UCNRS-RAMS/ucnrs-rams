require "rails_helper"

RSpec.describe "new.html.erb" do
  describe "it should have a progress bar" do
    it "with 4 steps" do
      user = create(:user, :confirmed)
      assign(:presenter, VisitsFormPresenter.new(user: user, current_step: 1))

      render template: "visits/new"
      doc = Capybara.string(rendered)

      expect(doc).to have_css(".progress-steps")
      expect(doc).to have_css("li", text: "Visit Details")
      expect(doc).to have_css("li", text: "Visitors")
      expect(doc).to have_css("li", text: "Reserve Info")
      expect(doc).to have_css("li", text: "Waivers & Policies")
    end

    it "with Visit Details as active step" do
      user = create(:user, :confirmed)
      assign(:presenter, VisitsFormPresenter.new(user: user, current_step: 1))

      render template: "visits/new"
      doc = Capybara.string(rendered)

      expect(doc).to have_css("li.active", text: "Visit Details")
    end
  end
end
