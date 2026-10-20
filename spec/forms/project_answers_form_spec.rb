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

    context "when a required question is submitted blank" do
      it "does not save a required yes/no question" do
        project = create(:project)
        question = create(:reserve_question, :boolean_question, location: :project, answer_required: true)
        form = ProjectAnswersForm.new(project: project, params: {
          reserve_answers: { question.id.to_s => { boolean_answer: "" } },
        })

        expect(form.save).to be_falsey
        expect(project.project_reserve_answers).to be_empty
      end

      it "does not save a required text question" do
        project = create(:project)
        question = create(:reserve_question, :text_question, location: :project, answer_required: true)
        form = ProjectAnswersForm.new(project: project, params: {
          reserve_answers: { question.id.to_s => { text_answer: "" } },
        })

        expect(form.save).to be_falsey
        expect(project.project_reserve_answers).to be_empty
      end

      it "rejects a required question omitted from the params and names it" do
        project = create(:project)
        question = create(
          :reserve_question, :boolean_question,
          location: :project, answer_required: true, question: "Any owls?", ignore_involvements: true
        )
        build(:project_reserve_answer, project: project, reserve_question: question, boolean_answer: nil)
          .save!(validate: false)
        form = ProjectAnswersForm.new(project: project, params: {})

        expect(form.save).to be_falsey
        expect(form.errors.full_messages).to eq([ "Please answer the required question: Any owls?" ])
      end

      it "saves required yes and no answers" do
        project = create(:project)
        yes_question = create(:reserve_question, :boolean_question, location: :project, answer_required: true)
        no_question = create(:reserve_question, :boolean_question, location: :project, answer_required: true)
        form = ProjectAnswersForm.new(project: project, params: {
          reserve_answers: {
            yes_question.id.to_s => { boolean_answer: "1" },
            no_question.id.to_s => { boolean_answer: "0" },
          },
        })

        expect(form.save).to be_truthy
        expect(project.project_reserve_answers.pluck(:boolean_answer)).to match_array([ true, false ])
      end

      it "does not save a permit answer left blank" do
        permit = create(:permit, involves_all: true)
        project = create(:project)
        form = ProjectAnswersForm.new(project: project, params: {
          permit_answers: { permit.id.to_s => { answer: "" } },
        })

        expect(form.save).to be_falsey
        expect(form.errors.full_messages).to eq([ "Please answer the permit question: #{permit.question}" ])
        expect(project.project_permit_answers).to be_empty
      end

      it "saves an optional question left blank" do
        project = create(:project)
        question = create(:reserve_question, :boolean_question, location: :project, answer_required: false)
        form = ProjectAnswersForm.new(project: project, params: {
          reserve_answers: { question.id.to_s => { boolean_answer: "" } },
        })

        expect(form.save).to be_truthy
      end
    end
  end
end
