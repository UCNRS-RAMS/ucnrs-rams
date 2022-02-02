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
end
