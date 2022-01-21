require "rails_helper"

RSpec.describe Projects::PermitAnswersController, type: :request do
  describe "/projects/:id/permit_answers" do
    it "does not error when there are no permit answers" do
      user = create(:user, :confirmed)
      project = create(:project, title: "Project 1", project_type: "Research")
      sign_in(user)

      post "/projects/#{project.id}/permit_answers", params: { project: { no_permits: "" } }
      follow_redirect!

      page = Capybara.string(response.body)
      expect(response).to be_ok
      expect(page).to have_css(".fundings-index")
    end
  end
end
