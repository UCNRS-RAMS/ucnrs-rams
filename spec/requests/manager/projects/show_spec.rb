require "rails_helper"

RSpec.describe Manager::ProjectsController, type: :request do
  let(:user) { create(:user, :confirmed) }
  let(:reserve) { create(:reserve, name: "Test Reserve") }

  before { create(:reserve_personnel, user: user, reserve: reserve) }

  describe "GET /manager/reserves/:reserve_id/projects/:id" do
    it "renders the summary box, tab menu and summary tab for a reserve manager" do
      project = create(:project, reserve: reserve)
      create(:project_team_membership, :principal_investigator, project: project, user: user)
      sign_in(user)

      get "/manager/reserves/#{reserve.id}/projects/#{project.id}"

      doc = Capybara.string(response.body)
      expect(response).to be_ok
      expect(doc).to have_css(".project-summary-box")
      expect(doc).to have_css("ul.project-menu-bar")
      expect(doc).to have_link(href: "/manager/reserves/#{reserve.id}/projects/#{project.id}")
      expect(doc).to have_link(href: "/manager/reserves/#{reserve.id}/projects/#{project.id}/visits")
      expect(doc).to have_link(href: "/manager/reserves/#{reserve.id}/projects/#{project.id}/detail/edit")
      expect(doc).to have_link(href: "/manager/reserves/#{reserve.id}/projects/#{project.id}/team_memberships")
      expect(doc).to have_link(href: "/manager/reserves/#{reserve.id}/projects/#{project.id}/permit/edit")
      expect(doc).to have_link(href: "/manager/reserves/#{reserve.id}/projects/#{project.id}/fundings")
      expect(doc).to have_link(href: "/manager/reserves/#{reserve.id}/projects/#{project.id}/activity_and_notes")
      expect(doc).to have_css(".project-summary-show")
      expect(doc).to have_css("#team-summary-table")
      expect(doc).to have_css("#funding-summary-table")
      expect(doc).to have_css("#permit-summary-list")
      expect(doc).to have_css("#reserve_question-summary-list")
    end

    it "shows the inactive team members alongside the active ones" do
      project = create(:project, reserve: reserve)
      create(:project_team_membership, project: project, active: true)
      create(:project_team_membership, project: project, active: false)
      sign_in(user)

      get "/manager/reserves/#{reserve.id}/projects/#{project.id}"

      doc = Capybara.string(response.body)
      expect(response).to be_ok
      expect(doc).to have_css("#team-summary-table tr.team-membership", count: 2)
      expect(doc).to have_css("#team-summary-table tr.inactive-user")
    end

    it "does not let a user who is not a manager of the reserve view the project" do
      project = create(:project, reserve: reserve)
      other_reserve = create(:reserve)
      non_manager = create(:user, :confirmed)
      create(:reserve_personnel, user: non_manager, reserve: other_reserve)
      sign_in(non_manager)

      get "/manager/reserves/#{reserve.id}/projects/#{project.id}"

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq I18n.t("manager.not_a_manager_of_reserve")
    end
  end
end
