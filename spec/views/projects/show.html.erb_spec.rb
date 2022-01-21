require "rails_helper"

RSpec.describe "show.html.erb" do
  describe "on any render" do
    it "includes sidebar" do
      project = create(:project)
      assign(:presenter, ProjectShowPresenter.new(project))

      render template: "projects/show"

      doc = Capybara.string(rendered)
      expect(doc).to have_css("section.sidebar")
      expect(doc).to have_css("ul.next-steps-list")
      expect(doc).to have_css("a", text: "Schedule A Visit")
    end


    it "includes project-summary" do
      project = create(:project)
      assign(:presenter, ProjectShowPresenter.new(project))

      render template: "projects/show"

      doc = Capybara.string(rendered)

      expect(doc).to have_css("section.project-summary")
      expect(doc).to have_css("a", text: "Edit Project")
    end
  end
end
