require "rails_helper"

RSpec.describe ReserveQuestionForm, type: :model do
  describe "delegations" do
    it { is_expected.to delegate_method(:valid?).to(:reserve_question) }
    it { is_expected.to delegate_method(:validate).to(:reserve_question) }
    it { is_expected.to delegate_method(:errors).to(:reserve_question) }
    it { is_expected.to delegate_missing_methods_to(:reserve_question) }
  end

  describe "initializing" do
    it "makes a new empty ReserveQuestionForm" do
      form = ReserveQuestionForm.new()

      expect(form).to have_attributes(
        id: nil,
        reserve_id: nil,
        question_type: nil,
        location: nil,
        question: nil,
        statement: nil,
        sort_order: nil,
        answer_required: false,
        public_use: true,
        university_class: true,
        research: true,
        housing: true,
        conference: false,
        visible: nil,
        authority: nil,
        description: nil,
        url_1: nil,
        url_link_text_1: nil,
        url_2: nil,
        url_link_text_2: nil,
        url_3: nil,
        url_link_text_3: nil,
        iacuc_flag: nil,
        drone_flag: nil,
        scuba_flag: nil,
        vertebrate_flag: nil,
        threatened_endangered_flag: nil,
        involves_mammals: nil,
        involves_reptiles: nil,
        involves_amphibians: nil,
        involves_fish: nil,
        involves_birds: nil,
        involves_plants_fungi_soil: nil
      )
    end

    it "makes a new ReserveQuestionForm from params" do
      params = {
        id: 5,
        reserve_id: 5,
        question_type: "text",
        location: "project",
        question: "question",
        statement: "statement",
        sort_order: 1,
        answer_required: true,
        public_use: false,
        university_class: false,
        research: false,
        housing: false,
        conference: true,
        visible: true,
        authority: nil,
        description: "description",
        url_1: "url1",
        url_link_text_1: "text1",
        url_2: "url2",
        url_link_text_2: "text2",
        url_3: "url3",
        url_link_text_3: "text3",
        iacuc_flag: true,
        drone_flag: true,
        scuba_flag: true,
        vertebrate_flag: true,
        threatened_endangered_flag: true,
        involves_mammals: true,
        involves_reptiles: true,
        involves_amphibians: true,
        involves_fish: true,
        involves_birds: true,
        involves_plants_fungi_soil: true,
      }
      form = ReserveQuestionForm.new(params: params)

      expect(form).to have_attributes(
        id: 5,
        reserve_id: 5,
        question_type: "text",
        location: "project",
        question: "question",
        statement: "statement",
        sort_order: 1,
        answer_required: true,
        public_use: false,
        university_class: false,
        research: false,
        housing: false,
        conference: true,
        visible: true,
        authority: nil,
        description: "description",
        url_1: "url1",
        url_link_text_1: "text1",
        url_2: "url2",
        url_link_text_2: "text2",
        url_3: "url3",
        url_link_text_3: "text3",
        iacuc_flag: true,
        drone_flag: true,
        scuba_flag: true,
        vertebrate_flag: true,
        threatened_endangered_flag: true,
        involves_mammals: true,
        involves_reptiles: true,
        involves_amphibians: true,
        involves_fish: true,
        involves_birds: true,
        involves_plants_fungi_soil: true,
      )
    end

    it "loads an existing reserve_question into ReserveQuestionForm from given reserve_question" do
      reserve_question = create(:reserve_question, question: "question1")
      form = ReserveQuestionForm.new(reserve_question: reserve_question)

      expect(form).to have_attributes(id: reserve_question.id, question: "question1")
    end

    context "when a reserve_question and params is given" do
      it "overwrites the given reserve_question attributes with the given params" do
        reserve_question = create(:reserve_question, question: "question old")
        form = ReserveQuestionForm.new(reserve_question: reserve_question, params: { question: "question new" })

        expect(form).to have_attributes(id: reserve_question.id, question: "question new")
      end
    end
  end

  describe "#save" do
    it "saves the reserve_question if there are no errors" do
      reserve_question = create(:reserve_question, question: "question old")
      form = ReserveQuestionForm.new(reserve_question: reserve_question, params: { question: "question new" })

      result = form.save

      expect(result).to be_truthy
      expect(form.reserve_question).to be_persisted
      expect(form.reserve_question).to have_attributes(id: reserve_question.id, question: "question new")
    end

    it "makes sure errors are visible when save fails" do
      form = ReserveQuestionForm.new()

      result = form.save

      expect(result).to be_falsy
      expect(form.reserve_question).to_not be_persisted
      expect(form.errors).to be_present
    end
  end
end
