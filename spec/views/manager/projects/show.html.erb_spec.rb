require "rails_helper"

RSpec.describe "show.html.erb" do
  let!(:user) { create(:user) }
  let!(:reserve) { create(:reserve) }

  before do
    without_partial_double_verification do
      allow(view).to receive(:current_reserve).and_return(reserve)
    end
  end

  describe "on any render" do
    it "includes summary box" do
      project = create(:project)
      assign(:presenter, Manager::ProjectShowPresenter.new(project: project, reserve: reserve, current_user: user))

      render template: "manager/projects/show", locals: { current_reserve: reserve }

      doc = Capybara.string(rendered)

      expect(doc).to have_css("section.project-summary-box")
      expect(doc).to have_css("div.info-block")
      expect(doc).to have_css("div.w-200")
      expect(doc).to have_css("p", text: "Project Number")
      expect(doc).to have_css("p", text: "Project Title")
      expect(doc).to have_css("p", text: "Reserve(s)")
      expect(doc).to have_css("p", text: "Date Created")
      expect(doc).to have_css("p", text: "Last Edited")
      expect(doc).to have_css("p", text: "Owner")
      expect(doc).to have_css("p", text: "Project Type")
    end

    describe "includes menu bar" do
      it "includes links" do
        project = create(:project)
        assign(:presenter, Manager::ProjectShowPresenter.new(project: project, reserve: reserve, current_user: user))

        render template: "manager/projects/show", locals: { current_reserve: reserve }

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
        assign(:presenter, Manager::ProjectShowPresenter.new(project: project, reserve: reserve, current_user: user))

        render template: "manager/projects/show"

        doc = Capybara.string(rendered)

        expect(doc).to have_css("a.active", text: "Summary")
      end
    end
  end
end
