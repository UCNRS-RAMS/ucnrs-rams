require "rails_helper"

RSpec.describe "show.html.erb" do
  describe "on any render" do
    it "includes summary box" do
      project = create(:project)
      assign(:presenter, Manager::ProjectShowPresenter.new(project))

      render template: "manager/projects/show"

      doc = Capybara.string(rendered)

      expect(doc).to have_css("section.project-summary-box")
      expect(doc).to have_css("div.info-block")
      expect(doc).to have_css("div.w-200")
      expect(doc).to have_css("p", text: "Project Number")
      expect(doc).to have_css("p", text: "Project Title")
      expect(doc).to have_css("p", text: "Reserve(s)")
      expect(doc).to have_css("p", text: "Date Created")
      expect(doc).to have_css("p", text: "Last Edited")
      expect(doc).to have_css("p", text: "Creator")
      expect(doc).to have_css("p", text: "Project Type")
    end

    describe "includes menu bar" do
      it "includes links" do
        project = create(:project)
        assign(:presenter, Manager::ProjectShowPresenter.new(project))

        render template: "manager/projects/show"

        doc = Capybara.string(rendered)

        expect(doc).to have_css("ul.project-menu-bar")
        expect(doc).to have_css("a.nav-link")
        expect(doc).to have_css("a", text: "Summary")
        expect(doc).to have_css("a", text: "Visits")
        expect(doc).to have_css("a", text: "Details")
        expect(doc).to have_css("a", text: "Team")
        expect(doc).to have_css("a", text: "Permits")
        expect(doc).to have_css("a", text: "Funding")
        expect(doc).to have_css("a", text: "Activity & Notes")
      end

      it "select summary by default" do
        project = create(:project)
        assign(:presenter, Manager::ProjectShowPresenter.new(project))

        render template: "manager/projects/show"

        doc = Capybara.string(rendered)

        expect(doc).to have_css("a.active", text: "Summary")
      end
    end

    it "includes project short info" do
      project = create(
        :project,
        project_type: :research,
        status: :incomplete,
        created_at: Time.zone.local(2004, 11, 24, 1, 4, 44),
      )
      assign(:presenter, Manager::ProjectShowPresenter.new(project))

      render template: "manager/projects/show"

      doc = Capybara.string(rendered)

      expected_info = "Incomplete Research Project Created: Nov. 24, 2004 at  1:04 AM"
      expect(doc).to have_css("p", text: expected_info)
    end

    describe "includes project team section" do
      it "has team summary table" do
        project = create(:project)
        create_list(:project_team_membership, 3, project: project)
        assign(:presenter, Manager::ProjectShowPresenter.new(project))

        render template: "manager/projects/show"

        doc = Capybara.string(rendered)

        expect(doc).to have_css("section.project-team")
        expect(doc).to have_css("a", text: "Edit Team")
        expect(doc).to have_css("table#team-summary-table")
        expect(doc).to_not have_css(".inactive-user")
      end

      it "includes inactive user class" do
        project = create(:project)
        create_list(:project_team_membership, 1, project: project, active: false)
        assign(:presenter, Manager::ProjectShowPresenter.new(project))

        render template: "manager/projects/show"

        doc = Capybara.string(rendered)

        expect(doc).to have_css(".inactive-user")
      end
    end

    it "includes project funding section" do
      project = create(:project)
      assign(:presenter, Manager::ProjectShowPresenter.new(project))

      render template: "manager/projects/show"

      doc = Capybara.string(rendered)

      expect(doc).to have_css("section.project-funding")
      expect(doc).to have_css("a", text: "Edit Funding")
      expect(doc).to have_css("table#funding-summary-table")
    end

    it "includes project permit section" do
      project = create(:project)
      assign(:presenter, Manager::ProjectShowPresenter.new(project))

      render template: "manager/projects/show"

      doc = Capybara.string(rendered)

      expect(doc).to have_css("section.project-permit")
      expect(doc).to have_css("a", text: "Edit Permits")
      expect(doc).to have_css("div#permit-summary-list")
    end
  end
end
