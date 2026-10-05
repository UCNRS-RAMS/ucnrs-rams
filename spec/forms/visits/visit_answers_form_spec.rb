require "rails_helper"

RSpec.describe Visits::VisitAnswersForm do
  describe "#save" do
    context "when the records are valid" do
      it "save answers" do
        project = create(:project)
        visit = create(:visit, project: project)
        answer1 = create(:visit_reserve_answer, visit: visit, boolean_answer: false)
        answer2 = create(:project_reserve_answer, project: visit.project, text_answer: "LOL")
        form = Visits::VisitAnswersForm.new(visit: visit, params: {
          visit_reserve_answers: {
            answer1.reserve_question_id.to_s => { boolean_answer: "1" },
          },
          project_reserve_answers: {
            answer2.reserve_question_id.to_s => { text_answer: "OMG" },
          },
        })

        form.save

        visit_reserve_answers = visit.visit_reserve_answers
        expect(visit_reserve_answers[0]).to have_attributes({
          reserve_question_id: answer1.reserve_question_id,
          visit_id: visit.id,
          boolean_answer: true,
        })
        project_reserve_answers = project.project_reserve_answers
        expect(project_reserve_answers[0]).to have_attributes({
          reserve_question_id: answer2.reserve_question_id,
          project_id: visit.project_id,
          text_answer: "OMG",
        })
      end
    end

    context "when a required yes/no question is submitted without a selection" do
      it "does not save" do
        visit = create(:visit)
        question = create(
          :reserve_question, :boolean_question,
          reserve: visit.reserve, location: :visit, answer_required: true
        )
        form = Visits::VisitAnswersForm.new(visit: visit, params: {
          visit_reserve_answers: { question.id.to_s => { boolean_answer: "" } },
        })

        expect(form.save).to be_falsey
        expect(visit.visit_reserve_answers).to be_empty
      end
    end
  end
end
