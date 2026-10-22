require "rails_helper"

RSpec.describe "Visit questions on draft visits (ngRAMS#213)", type: :request do
  let(:user) { create(:user, :confirmed) }
  let(:reserve) { create(:reserve) }
  let(:project) { create(:project) }

  before do
    create(:project_team_membership, user: user, project: project, active: true, can_edit_project: true)
    sign_in(user)
  end

  describe "GET /visits/:id/questions" do
    it "shows the visit-level question on a first visit when project answers already exist" do
      project_question = create(
        :reserve_question, :boolean_question, reserve: reserve, location: :project, ignore_involvements: true
      )
      create(
        :reserve_question, :boolean_question,
        reserve: reserve, location: :visit, answer_required: true, question: "Every visit?", ignore_involvements: true
      )
      create(:project_reserve_answer, project: project, reserve_question: project_question, boolean_answer: true)
      visit = create(:visit, reserve: reserve, project: project, submitted_at: nil)
      create(:user_visit, visit: visit, user: user)

      get "/visits/#{visit.id}/questions"

      expect(response).to be_ok
      expect(Capybara.string(response.body)).to have_text("Every visit?")
    end

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
