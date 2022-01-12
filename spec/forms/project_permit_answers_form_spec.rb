require "rails_helper"

RSpec.describe ProjectPermitAnswersForm do
  describe "#answer_form" do
    it "returns a ProjectPermitAnswerForm for the given permit id" do
      permit1 = build_stubbed(:permit, involves_all: true)
      permit2 = build_stubbed(:permit, involves_all: true)
      project = build_stubbed(:project)
      form = ProjectPermitAnswersForm.new(project: project, params: {
        permit1.id.to_s => "1"
      })

      result = form.answer_form(permit1.id)

      expect(result).to have_attributes({
        permit_id: permit1.id,
        project_id: project.id,
        answer: "1",
      })
    end
  end
end
