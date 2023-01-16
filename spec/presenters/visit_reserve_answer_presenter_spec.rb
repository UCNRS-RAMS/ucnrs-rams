require "rails_helper"

RSpec.describe VisitReserveAnswerPresenter do
  describe "delegations" do
    subject { VisitReserveAnswerPresenter.new(build(:visit_reserve_answer)) }
    it { is_expected.to delegate_missing_methods_to(:visit_reserve_answer) }
    it { is_expected.to delegate_method(:reserve_name).to(:reserve_question) }
    it { is_expected.to delegate_method(:statement).to(:reserve_question).with_prefix(true) }
    it { is_expected.to delegate_method(:question).to(:reserve_question).with_prefix(true) }
  end

  describe "#answer" do
    context "when question type is boolean and answer is true" do
      it "presents the reserve question statement" do
        question1 = create(:reserve_question, question_type: "Boolean", statement: "yes to this question")
        answer1 = create(
          :visit_reserve_answer,
          reserve_question: question1,
          boolean_answer: true,
          text_answer: "text answer",
        )

        presenter = VisitReserveAnswerPresenter.new(answer1)

        expect(presenter.answer).to eq "yes to this question"
      end
    end

    context "when question type is text" do
      it "presents the text answer" do
        question1 = create(:reserve_question, question_type: "Text")
        answer1 = create(
          :visit_reserve_answer,
          reserve_question: question1,
          boolean_answer: true,
          text_answer: "text answer",
        )

        presenter = VisitReserveAnswerPresenter.new(answer1)

        expect(presenter.answer).to eq "text answer"
      end
    end
  end
end
