require "rails_helper"

RSpec.describe ReserveQuestion, type: :model do
  describe "assocations" do
    it { is_expected.to belong_to(:reserve) }
  end

  describe "validations" do
    subject { create(:reserve_question) }

    it { is_expected.to validate_presence_of(:question_type) }
    it { is_expected.to validate_presence_of(:question) }
    it { is_expected.to validate_presence_of(:location) }
    it { is_expected.to validate_uniqueness_of(:sort_order).scoped_to([:reserve_id, :location]) }
    it { is_expected.to validate_booleanish_values(:visible) }
    it { is_expected.to validate_booleanish_values(:answer_required) }
    it { is_expected.to validate_booleanish_values(:public_use) }
    it { is_expected.to validate_booleanish_values(:university_class) }
    it { is_expected.to validate_booleanish_values(:research) }
    it { is_expected.to validate_booleanish_values(:housing) }
    it { is_expected.to validate_booleanish_values(:conference) }
  end

  describe "enums" do
    it do
      is_expected.to define_enum_for(:location)
        .with_values(
          visit: "visit",
          project: "project",
        ).backed_by_column_of_type(:string)
    end

    it do
      is_expected.to define_enum_for(:question_type)
        .with_values(
          boolean: "Boolean",
          text: "Text",
        ).backed_by_column_of_type(:string)
    end
  end

  describe "#reserve_name" do
    it "returns the reserve name of the reserve record associated with the reserve question." do
      reserve = create(:reserve, name: "Over Under Reserve")
      reserve_question = create(:reserve_question, reserve: reserve)

      expect(reserve_question.reserve_name).to eq "Over Under Reserve"
    end
  end

  describe ".in_order" do
    it "returns records in order of sort_order" do
      one = create(:reserve_question, sort_order: 2)
      two = create(:reserve_question, sort_order: 1)

      results = ReserveQuestion.in_order

      expect(results).to eq [two, one]
    end
  end

  describe ".for_projects" do
    it "only selects records with a location of 'project'" do
      project_question = create(:reserve_question, location: :project)
      visit_question = create(:reserve_question, location: :visit)

      results = ReserveQuestion.for_projects

      expect(results).to eq [project_question]
    end
  end

  describe ".visible" do
    it "only selects records that are visible" do
      visible = create(:reserve_question, visible: true)
      not_visible = create(:reserve_question, visible: false)

      results = ReserveQuestion.visible

      expect(results).to eq [visible]
    end
  end

  describe ".with_answers_for_project" do
    it "returns reserve questions with added fields for #boolean_answer and #text_answer from associated ProjectReserveAnswers" do
      project = create(:project)
      question1 = create(:reserve_question, :boolean_question)
      answer1 = create(
        :project_reserve_answer,
        project: project,
        reserve_question: question1,
        boolean_answer: true,
        text_answer: nil,
      )
      question2 = create(:reserve_question, :text_question)
      answer2 = create(
        :project_reserve_answer,
        project: project,
        reserve_question: question2,
        boolean_answer: false,
        text_answer: "Something relevant",
      )
      question3 = create(:reserve_question)

      questions = ReserveQuestion
        .with_answers_for_project(project)
        .order(:id)

      expect(questions.length).to eq 2
      expect(questions[0]).to eq question1
      expect(questions[0].text_answer).to eq nil
      expect(questions[0].boolean_answer).to eq 1
      expect(questions[1]).to eq question2
      expect(questions[1].text_answer).to eq "Something relevant"
      expect(questions[1].boolean_answer).to eq 0
    end
  end

  describe ".by_location" do
    it "returns records in order alphabetically by location" do
      reserve_question1 = create(:reserve_question, location: "project")
      reserve_question2 = create(:reserve_question, location: "visit")
      reserve_question3 = create(:reserve_question, location: "project")

      results = ReserveQuestion.by_location

      expect(results).to eq [reserve_question1, reserve_question3, reserve_question2]
    end
  end
end
