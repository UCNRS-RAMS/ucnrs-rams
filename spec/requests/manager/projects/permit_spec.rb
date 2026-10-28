require "rails_helper"

RSpec.describe Manager::Projects::PermitController, type: :request do
  describe "GET /manager/reserves/:reserve_id/projects/:project_id/permit/edit" do
    it "renders the permit questions for the project" do
      user = create(:user, :confirmed)
      reserve = create(:reserve)
      project = create(:project, involves_mammals: true, reserve: reserve)
      create(:permit, involves_all: true)
      create(:reserve_personnel, user: user, reserve: reserve)
      sign_in(user)

      get "/manager/reserves/#{reserve.id}/projects/#{project.id}/permit/edit"

      page = Capybara.string(response.body)
      expect(response).to be_ok
      expect(page).to have_css("#project-permit-edit")
      expect(page).to have_css("#permit-questions")
    end
  end

  describe "/manager/reserves/:reserve_id/projects/:project_id/permit" do
    it "does not return error when there are no permit" do
      user = create(:user, :confirmed)
      reserve = create(:reserve)
      project = create(:project, involves_mammals: true, reserve: reserve)
      create(:reserve_personnel, user: user, reserve: reserve)
      sign_in(user)

      post "/manager/reserves/#{reserve.id}/projects/#{project.id}/permit", params: { project: { no_permits: "" } }
      follow_redirect!

      page = Capybara.string(response.body)
      expect(response).to be_ok
      expect(page).to have_css(".project-summary-box")
    end
  end
end
