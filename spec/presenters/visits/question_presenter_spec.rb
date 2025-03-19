require "rails_helper"

RSpec.describe Visits::QuestionPresenter do
  describe "delegations" do
    subject { Visits::QuestionPresenter.new(build(:reserve_question)) }
    it { is_expected.to delegate_missing_methods_to(:question) }
  end

  describe "#render_values" do
    it "is a hash containing a path to the partial and locals" do
      presenter = Visits::QuestionPresenter.new(build_stubbed(:permit))

      expect(presenter.render_values).to eq({
        partial: "shared/visits/questions/question",
        locals: { question: presenter },
      })
    end
  end

  describe "#urls" do
    it "returns a hash of urls and their descriptions" do
      question = create(
        :reserve_question,
        url_1: "www.foo1.com",
        url_link_text_1: "Foo 1",
        url_2: "www.foo2.com",
        url_link_text_2: "Foo 2",
        url_3: "www.foo3.com",
        url_link_text_3: "Foo 3",
      )
      presenter = Visits::QuestionPresenter.new(question)

      expect(presenter.urls).to include(
        "www.foo1.com" => "Foo 1",
        "www.foo2.com" => "Foo 2",
        "www.foo3.com" => "Foo 3",
      )
    end

    it "does not include the key/value pair if the url and descriptions are nil" do
      question = create(
        :reserve_question,
        url_1: "www.foo1.com",
        url_link_text_1: "Foo 1",
        url_2: nil,
        url_link_text_2: nil,
        url_3: "www.foo3.com",
        url_link_text_3: "Foo 3",
      )
      presenter = Visits::QuestionPresenter.new(question)

      expect(presenter.urls).to include(
        "www.foo1.com" => "Foo 1",
        "www.foo3.com" => "Foo 3",
      )
    end
  end

  describe "#reserve_name" do
    it "is the name of the reserve associated with the question" do
      reserve = create(:reserve, name: "Big Horn Ranch")
      question = create(:reserve_question, reserve: reserve)
      presenter = Visits::QuestionPresenter.new(question)

      expect(presenter.reserve_name).to eq "Big Horn Ranch"
    end
  end

  describe "#answer" do
    it "returns the boolean_answer as a string if the question type is boolean" do
      question = create(:reserve_question, question_type: :boolean)
      mock_reserve_answer(question, boolean: true)
      presenter = Visits::QuestionPresenter.new(question)

      expect(presenter.answer).to eq(1)
    end

    it "returns the text_answer if the question type is not boolean" do
      question = create(:reserve_question, question_type: :text)
      mock_reserve_answer(question, text: "What does the fox say?")
      presenter = Visits::QuestionPresenter.new(question)

      expect(presenter.answer).to eq("What does the fox say?")
    end
  end

  describe "#boolean_answer" do
    it "returns '1' if the answer is true, because it's a tinyint in the db" do
      question = create(:reserve_question, question_type: :boolean)
      mock_reserve_answer(question, boolean: true)
      presenter = Visits::QuestionPresenter.new(question)

      expect(presenter.boolean_answer).to eq(1)
    end

    it "returns '0' if the answer is false" do
      question = create(:reserve_question, question_type: :boolean)
      mock_reserve_answer(question, boolean: false)
      presenter = Visits::QuestionPresenter.new(question)

      expect(presenter.boolean_answer).to eq(0)
    end
  end
end
