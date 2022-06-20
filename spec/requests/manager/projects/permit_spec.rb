require "rails_helper"

RSpec.describe Manager::Projects::PermitController, type: :request do
  describe "/manager/reserves/:reserve_id/projects/:project_id/permit" do
    it "does not return error when there are no permit" do
      user = create(:user, :confirmed)
      project = create(:project, involves_mammals: true)
      reserve = create(:reserve)
      sign_in(user)

      post "/manager/reserves/#{reserve.id}/projects/#{project.id}/permit", params: { project: { no_permits: "" } }
      follow_redirect!

      page = Capybara.string(response.body)
      expect(response).to be_ok
      expect(page).to have_css(".project-summary-box")
    end
  end
end
