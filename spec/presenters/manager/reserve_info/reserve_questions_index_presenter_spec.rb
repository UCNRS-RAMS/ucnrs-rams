require "rails_helper"

RSpec.describe Manager::ReserveInfo::ReserveQuestionsIndexPresenter do
  describe "#reserve_questions" do
    it "creates a ReserveQuestionPresenter for each reserve_question" do
      reserve = create(:reserve)
      reserve_question1 = create(:reserve_question, reserve: reserve)
      reserve_question2 = create(:reserve_question)
      reserve_question3 = create(:reserve_question, reserve: reserve)
      presenter = Manager::ReserveInfo::ReserveQuestionsIndexPresenter.new(reserve: reserve)

      results = presenter.reserve_questions

      expect(results).to all(be_a(ReserveQuestionPresenter))
      expect(results.map(&:id)).to eq [reserve_question1.id, reserve_question3.id]
    end
  end

  describe "#reserve_questions_scope" do
    it "returns reserve_questions from the given reserve" do
      reserve = create(:reserve)
      reserve_question1 = create(:reserve_question, reserve: reserve)
      reserve_question2 = create(:reserve_question)
      reserve_question3 = create(:reserve_question, reserve: reserve)
      presenter = Manager::ReserveInfo::ReserveQuestionsIndexPresenter.new(reserve: reserve)

      results = presenter.reserve_questions_scope

      expect(results).to match_array [reserve_question1, reserve_question3]
    end

    it "returns reserve_questions in sort_order" do
      reserve = create(:reserve)
      reserve_question1 = create(:reserve_question, reserve: reserve, sort_order: 3)
      reserve_question2 = create(:reserve_question, reserve: reserve, sort_order: 1)
      reserve_question3 = create(:reserve_question, reserve: reserve, sort_order: 2)
      presenter = Manager::ReserveInfo::ReserveQuestionsIndexPresenter.new(reserve: reserve)

      results = presenter.reserve_questions_scope

      expect(results).to eq [reserve_question2, reserve_question3, reserve_question1]
    end
  end
end
