require "rails_helper"

RSpec.describe ProjectAnswerForm do
  describe "#answer" do
    it "returns '1' if the answer is Yes" do
      permit = build_stubbed(:permit, involves_all: true)
      project = build_stubbed(:project)
      form = ProjectAnswerForm.new(project: project, params: {
        permit_id: permit.id,
        answer: "1",
      })

      expect(form.answer).to eq "1"
    end

    it "returns '0' if the answer is anything else" do
      permit = build_stubbed(:permit, involves_all: true)
      project = build_stubbed(:project)
      form = ProjectAnswerForm.new(project: project, params: {
        permit_id: permit.id,
        answer: "I already told you no!",
      })

      expect(form.answer).to eq "0"
    end
  end
end
