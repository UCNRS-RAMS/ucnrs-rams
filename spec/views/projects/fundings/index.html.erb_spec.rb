require "rails_helper"

RSpec.describe "app/views/projects/fundings/index.html.erb" do
  describe "on any render" do
    it "has the correct title" do
      render template: "projects/fundings/index"

      doc = Capybara.string(rendered)
      expect(doc).to have_css("h1", text: "Funding")
    end
  end
end
