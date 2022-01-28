require "rails_helper"

RSpec.describe ProjectPermitAnswersForm do
  describe "#answer_form" do
    it "returns a ProjectPermitAnswerForm for the given permit id" do
      permit1 = build_stubbed(:permit, involves_all: true)
      permit2 = build_stubbed(:permit, involves_all: true)
      project = build_stubbed(:project)
      form = ProjectPermitAnswersForm.new(project: project, params: {
        answers: { permit1.id.to_s =>  { answer: "1" } },
      })

      result = form.answer_form(permit1.id)

      expect(result).to have_attributes({
        permit_id: permit1.id,
        project_id: project.id,
        answer: "1",
      })
    end
  end

  describe "#save" do
    context "when the records are valid" do
      it "saves the project and the project_permit_answers" do
        permit1 = create(:permit, involves_all: true)
        permit2 = create(:permit, involves_all: true)
        project = create(:project)
        form = ProjectPermitAnswersForm.new(project: project, params: {
          answers: {
            permit1.id.to_s => { answer: "1" },
            permit2.id.to_s => { answer: "0" },
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
      end
    end
  end
end
