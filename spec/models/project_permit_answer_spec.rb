require "rails_helper"

RSpec.describe ProjectPermitAnswer, type: :model do
  describe "assocations" do
    it { is_expected.to belong_to(:permit) }
    it { is_expected.to belong_to(:project) }
  end

  describe "validations" do
    it { is_expected.to validate_booleanish_values(:answer) }
  end

  describe ".for_project" do
    context "when project passed in" do
      it "returns records for given project" do
        project = create(:project)
        project_permit_answer1 = create(:project_permit_answer, project: project)
        project_permit_answer2 = create(:project_permit_answer)
        project_permit_answer3 = create(:project_permit_answer, project: project)

        results = ProjectPermitAnswer.for_project(project)

        expect(results).to eq [project_permit_answer1, project_permit_answer3]
      end
    end

    context "when project passed in is nil" do
      it "returns all when project" do
        project = create(:project)
        project_permit_answer1 = create(:project_permit_answer, project: project)
        project_permit_answer2 = create(:project_permit_answer)
        project_permit_answer3 = create(:project_permit_answer, project: project)

        results = ProjectPermitAnswer.for_project(nil)

        expect(results).to eq [project_permit_answer1, project_permit_answer2, project_permit_answer3]
      end
    end
  end

  describe ".for_answer" do
    context "when answer is passed in" do
      it "returns records for given answer" do
        project = create(:project)
        project_permit_answer1 = create(:project_permit_answer, answer: true)
        project_permit_answer2 = create(:project_permit_answer, answer: false)
        project_permit_answer3 = create(:project_permit_answer, answer: true)

        results = ProjectPermitAnswer.for_answer(true)

        expect(results).to eq [project_permit_answer1, project_permit_answer3]
      end
    end

    context "when answer is passed in is nil" do
      it "returns all answer records" do
        project = create(:project)
        project_permit_answer1 = create(:project_permit_answer, answer: true)
        project_permit_answer2 = create(:project_permit_answer, answer: false)
        project_permit_answer3 = create(:project_permit_answer, answer: true)

        results = ProjectPermitAnswer.for_answer(nil)

        expect(results).to eq [project_permit_answer1, project_permit_answer2, project_permit_answer3]
      end
    end
  end

  describe ".replace_all" do
    it "does nothing if the argument is empty" do
      existing_answer = create(:project_permit_answer, answer: false)
      existing_answer.answer = true

      ProjectPermitAnswer.replace_all([])

      expect(existing_answer.reload).to eq existing_answer
    end

    it "REPLACEs the objects passed in" do
      existing_answer = create(:project_permit_answer, answer: false)
      project = existing_answer.project
      existing_answer.answer = true
      permit = create(:permit)
      new_answer = build(:project_permit_answer, project: project, permit: permit, answer: true)

      ProjectPermitAnswer.replace_all([existing_answer, new_answer])

      existing_answer = ProjectPermitAnswer
        .where(project: project, permit: existing_answer.permit)
        .first
      new_answer = ProjectPermitAnswer
        .where(project: project, permit: new_answer.permit)
        .first
      expect(existing_answer.answer).to be true
      expect(new_answer.answer).to be true
      expect(new_answer).to be_persisted
    end
  end
end
