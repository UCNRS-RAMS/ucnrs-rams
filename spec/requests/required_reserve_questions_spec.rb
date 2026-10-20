require "rails_helper"

RSpec.describe "Required reserve questions (ngRAMS#213)", type: :request do
  let(:user) { create(:user, :confirmed) }
  let(:reserve) { create(:reserve) }
  let(:project) { create(:project) }

  before do
    create(:project_team_membership, user: user, project: project, active: true, can_edit_project: true)
    sign_in(user)
  end

  describe "project questions step" do
    it "rejects a blank required answer, names the question, and keeps other answers" do
      required = create(
        :reserve_question, :boolean_question,
        reserve: reserve, location: :project, answer_required: true, question: "Any owls?", ignore_involvements: true
      )
      optional = create(
        :reserve_question, :text_question,
        reserve: reserve, location: :project, answer_required: false, ignore_involvements: true
      )
      build(:project_reserve_answer, project: project, reserve_question: required, boolean_answer: nil)
        .save!(validate: false)
      create(:project_reserve_answer, project: project, reserve_question: optional, text_answer: "stored")

      post "/projects/#{project.id}/answers", params: { project: { reserve_answers: {
        required.id.to_s => { boolean_answer: "" },
        optional.id.to_s => { text_answer: "typed just now" }
      } } }

      doc = Capybara.string(response.body)
      expect(response).to have_http_status(:unprocessable_content)
      expect(doc).to have_css("[role='alert'] .error", text: "Please answer the required question: Any owls?")
      expect(doc).to have_css("textarea", text: "typed just now")
      expect(project.project_reserve_answers.find_by(reserve_question: optional).text_answer).to eq "stored"
    end

    it "moves on when every required question is answered" do
      required = create(
        :reserve_question, :boolean_question,
        reserve: reserve, location: :project, answer_required: true, ignore_involvements: true
      )
      create(:project_reserve_answer, project: project, reserve_question: required, boolean_answer: false)

      post "/projects/#{project.id}/answers", params: { project: { reserve_answers: {
        required.id.to_s => { boolean_answer: "0" }
      } } }

      expect(response).to redirect_to(project_fundings_path(project))
    end
  end

  describe "second visit to the same project and reserve" do
    it "still shows the required visit-level question" do
      project_question = create(
        :reserve_question, :boolean_question, reserve: reserve, location: :project, ignore_involvements: true
      )
      visit_question = create(
        :reserve_question, :boolean_question,
        reserve: reserve, location: :visit, answer_required: true, question: "Every visit?", ignore_involvements: true
      )
      first_visit = create(:visit, reserve: reserve, project: project, submitted_at: nil)
      create(:user_visit, visit: first_visit, user: user)
      create(:project_reserve_answer, project: project, reserve_question: project_question, boolean_answer: true)
      create(:visit_reserve_answer, visit: first_visit, reserve_question: visit_question, boolean_answer: true)
      second_visit = create(:visit, reserve: reserve, project: project, submitted_at: nil)
      create(:user_visit, visit: second_visit, user: user)

      get "/visits/#{second_visit.id}/questions"

      doc = Capybara.string(response.body)
      expect(response).to be_ok
      expect(doc).to have_text("Every visit?")
    end
  end
end
