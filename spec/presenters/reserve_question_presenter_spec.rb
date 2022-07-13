require "rails_helper"

RSpec.describe ReserveQuestion do
  describe "delegations" do
    subject { ReserveQuestionPresenter.new(build(:reserve_question)) }
    it { is_expected.to delegate_method(:id).to(:reserve_question) }
    it { is_expected.to delegate_method(:location).to(:reserve_question) }
    it { is_expected.to delegate_method(:sort_order).to(:reserve_question) }
    it { is_expected.to delegate_method(:question).to(:reserve_question) }
    it { is_expected.to delegate_method(:statement).to(:reserve_question) }
    it { is_expected.to delegate_method(:answer_required).to(:reserve_question) }
    it { is_expected.to delegate_method(:visible).to(:reserve_question) }
  end

  describe "#location_project_types" do
    it "returns array containing correct the project types locations" do
      reserve_question = create(:reserve_question, research: true, university_class: false, public_use: true, housing: false, conference: true)

      reserve_question_presenter = ReserveQuestionPresenter.new(reserve_question)

      expect(reserve_question_presenter.location_project_types).to eq ["Research", "Public Use", "Conference"]
    end
  end

  describe "#type" do
    it "returns 'text' when reserve question type is 'text'" do
      text_reserve_question = create(:reserve_question, question_type: "text")

      reserve_question_presenter = ReserveQuestionPresenter.new(text_reserve_question)

      expect(reserve_question_presenter.type).to eq "Text"
    end

    it "returns 'yes/no' when reserve question type is 'boolean'" do
      boolean_reserve_question = create(:reserve_question, question_type: "boolean")

      reserve_question_presenter = ReserveQuestionPresenter.new(boolean_reserve_question)

      expect(reserve_question_presenter.type).to eq "Yes/No"
    end
  end
end
