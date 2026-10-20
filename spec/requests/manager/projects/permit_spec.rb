require "rails_helper"

RSpec.describe Manager::Projects::PermitController, type: :request do
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

    it "re-renders the manager form on rejection and accepts the corrected submission" do
      user = create(:user, :confirmed)
      reserve = create(:reserve)
      project = create(:project, reserve: reserve)
      create(:reserve_personnel, user: user, reserve: reserve)
      question = create(
        :reserve_question, :boolean_question,
        reserve: reserve, location: :project, answer_required: true, ignore_involvements: true
      )
      build(:project_reserve_answer, project: project, reserve_question: question, boolean_answer: nil)
        .save!(validate: false)
      sign_in(user)
      path = "/manager/reserves/#{reserve.id}/projects/#{project.id}/permit"

      post path, params: { project: { reserve_answers: { question.id.to_s => { boolean_answer: "" } } } }

      expect(response).to have_http_status(:unprocessable_content)
      doc = Capybara.string(response.body)
      expect(doc).to have_css("form#questions[action='#{path}']")
      expect(doc).to have_css("[role='alert'] .error")

      post path, params: { project: { reserve_answers: { question.id.to_s => { boolean_answer: "1" } } } }

      expect(response).to redirect_to("/manager/reserves/#{reserve.id}/projects/#{project.id}")
    end
  end
end
