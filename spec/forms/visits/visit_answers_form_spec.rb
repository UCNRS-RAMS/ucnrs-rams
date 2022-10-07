require "rails_helper"

RSpec.describe Visits::VisitAnswersForm do
  describe "#save" do
    context "when the records are valid" do
      it "save answers" do
        visit = create(:visit)
        answer1 = create(:visit_reserve_answer, visit: visit, boolean_answer: false)
        answer2 = create(:visit_reserve_answer, visit: visit, text_answer: "LOL")
        form = Visits::VisitAnswersForm.new(visit: visit, params: {
          reserve_answers: {
            answer1.reserve_question_id.to_s => { boolean_answer: "1" },
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
        expect(visit_reserve_answers[1]).to have_attributes({
          reserve_question_id: answer2.reserve_question_id,
          visit_id: visit.id,
          text_answer: "OMG",
        })
      end
    end
  end
end
