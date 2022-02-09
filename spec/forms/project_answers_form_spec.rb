require "rails_helper"

RSpec.describe ProjectAnswersForm do
  describe "#save" do
    context "when the records are valid" do
      it "saves the project, permit, and reserve answers" do
        permit1 = create(:permit, involves_all: true)
        permit2 = create(:permit, involves_all: true)
        project = create(:project)
        answer1 = create(:project_reserve_answer, project: project, boolean_answer: false)
        answer2 = create(:project_reserve_answer, project: project, text_answer: "LOL")
        form = ProjectAnswersForm.new(project: project, params: {
          permit_answers: {
            permit1.id.to_s => { answer: "1" },
            permit2.id.to_s => { answer: "0" },
          },
          reserve_answers: {
            answer1.reserve_question_id.to_s => { boolean_answer: "1" },
            answer2.reserve_question_id.to_s => { text_answer: "OMG" },
          },
          approved_permits: "Approved ones only!",
        })

        form.save

        project_permit_answers = project.project_permit_answers
        expect(project).to be_valid
        expect(project.approved_permits).to eq "Approved ones only!"
        expect(project_permit_answers[0]).to have_attributes({
          permit_id: permit1.id,
          project_id: project.id,
          answer: true,
        })
        expect(project_permit_answers[1]).to have_attributes({
          permit_id: permit2.id,
          project_id: project.id,
          answer: false,
        })
        project_reserve_answers = project.project_reserve_answers
        expect(project_reserve_answers[0]).to have_attributes({
          reserve_question_id: answer1.reserve_question_id,
          project_id: project.id,
          boolean_answer: true,
        })
        expect(project_reserve_answers[1]).to have_attributes({
          reserve_question_id: answer2.reserve_question_id,
          project_id: project.id,
          text_answer: "OMG",
        })
      end
    end
  end
end
