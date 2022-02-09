require "rails_helper"

RSpec.describe ProjectReserveAnswer, type: :model do
  describe "assocations" do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:reserve_question) }
  end

  describe ".for_project" do
    context "when project passed in" do
      it "returns records for given project" do
        project = create(:project)
        project_reserve_answer1 = create(:project_reserve_answer, project: project)
        project_reserve_answer2 = create(:project_reserve_answer)
        project_reserve_answer3 = create(:project_reserve_answer, project: project)

        results = ProjectReserveAnswer.for_project(project)

        expect(results).to eq [project_reserve_answer1, project_reserve_answer3]
      end
    end

    context "when project passed in is nil" do
      it "returns all when project" do
        project = create(:project)
        project_reserve_answer1 = create(:project_reserve_answer, project: project)
        project_reserve_answer2 = create(:project_reserve_answer)
        project_reserve_answer3 = create(:project_reserve_answer, project: project)

        results = ProjectReserveAnswer.for_project(nil)

        expect(results).to eq [project_reserve_answer1, project_reserve_answer2, project_reserve_answer3]
      end
    end
  end

  describe ".with_reserve_name_column" do
    it "returns records for given project including an attribute for reserve_name" do
      reserve = create(:reserve, name: "Over Under Reserve")
      reserve_question = create(:reserve_question, reserve: reserve)
      project_reserve_answer = create(:project_reserve_answer, reserve_question: reserve_question)

      results = ProjectReserveAnswer.with_reserve_name_column

      expect(results.first.reserve_name).to eq "Over Under Reserve"
    end
  end

  describe ".with_affirmative_answer" do
      it "returns records for only non 'no' answer" do
        project_reserve_answer1 = create(:project_reserve_answer, boolean_answer: true)
        project_reserve_answer2 = create(:project_reserve_answer, boolean_answer: false)
        project_reserve_answer3 = create(:project_reserve_answer, text_answer: 'yes')
        project_reserve_answer4 = create(:project_reserve_answer, text_answer: nil)

        results = ProjectReserveAnswer.with_affirmative_answer

        expect(results).to eq [project_reserve_answer1, project_reserve_answer3]
      end
  end

  describe ".replace_all" do
    it "does nothing if the argument is empty" do
      existing_answer = create(:project_reserve_answer, boolean_answer: false)
      existing_answer.boolean_answer = true

      ProjectPermitAnswer.replace_all([])

      expect(existing_answer.reload).to eq existing_answer
    end

    it "INSERTs the objects passed in and UPDATES if there are conflicts" do
      existing_answer = travel_to(1.day.ago) do
        create(:project_reserve_answer, boolean_answer: false)
      end
      project = existing_answer.project
      existing_answer.boolean_answer = true
      reserve_question = create(:reserve_question, question_type: :boolean)
      new_answer = build(:project_reserve_answer, project: project, reserve_question: reserve_question, boolean_answer: true)

      ProjectReserveAnswer.replace_all([existing_answer, new_answer])

      existing_answer = ProjectReserveAnswer
        .where(project: project, reserve_question: existing_answer.reserve_question)
        .first
      new_answer = ProjectReserveAnswer
        .where(project: project, reserve_question: new_answer.reserve_question)
        .first
      expect(existing_answer.boolean_answer).to be true
      expect(new_answer.boolean_answer).to be true
      expect(new_answer).to be_persisted
      expect(Time.current - existing_answer.created_at).to be >= 1.day
    end
  end
end
