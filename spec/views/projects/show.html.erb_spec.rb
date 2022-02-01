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
      expect(doc).to have_css("a[href='/projects/#{project.id}/edit']", text: "Edit Project")
    end

    it "includes project team section" do
      project = create(:project)
      assign(:presenter, ProjectShowPresenter.new(project))

      render template: "projects/show"

      doc = Capybara.string(rendered)

      expect(doc).to have_css("section.project-team")
      expect(doc).to have_css("a", text: "Edit Team")
      expect(doc).to have_css("table#team-summary-table")
    end

    it "includes project funding section" do
      project = create(:project)
      assign(:presenter, ProjectShowPresenter.new(project))

      render template: "projects/show"

      doc = Capybara.string(rendered)

      expect(doc).to have_css("section.project-funding")
      expect(doc).to have_css("a", text: "Edit Funding")
      expect(doc).to have_css("table#funding-summary-table")
    end

    it "includes project permit section" do
      project = create(:project)
      assign(:presenter, ProjectShowPresenter.new(project))

      render template: "projects/show"

      doc = Capybara.string(rendered)
      
      expect(doc).to have_css("section.project-permit")
      expect(doc).to have_css("a", text: "Edit Permits")
      expect(doc).to have_css("div#permit-summary-list")
    end
    
    it "includes project visits section" do
      project = create(:project)
      assign(:presenter, ProjectShowPresenter.new(project))

      render template: "projects/show"

      doc = Capybara.string(rendered)
      
      expect(doc).to have_css("section.project-visits")
      expect(doc).to have_css(".content a", text: "Schedule A Visit")
      expect(doc).to have_css("table#project-visit-requests")
    end
  end
end
