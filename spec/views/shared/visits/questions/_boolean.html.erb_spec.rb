require "rails_helper"

RSpec.describe "shared/visits/questions/_boolean.html.erb", type: :view do
  it "renders the question and yes/no answers" do
    question = create(:reserve_question, question: "Hi?", location: :visit)
    mock_reserve_answer(question, boolean: false)
    presenter = Visits::QuestionPresenter.new(question)

    FakeForm.fields_for(presenter) do |f|
      render partial: "shared/visits/questions/boolean", locals: { question: presenter, f: f }
    end

    doc = Capybara.string(rendered)
    expect(doc).to have_css(".field", text: question.question)
    expect(doc).to have_css(".yes-no-options input[type='radio'][value='1']")
    expect(doc).to have_css(".yes-no-options input[type='radio'][value='0']")
  end

  it "submits a blank answer so an unselected required question is validated" do
    question = create(:reserve_question, location: :visit, answer_required: true)
    allow(question).to receive_messages(boolean_answer: nil, text_answer: nil)
    presenter = Visits::QuestionPresenter.new(question)

    FakeForm.fields_for(presenter) do |f|
      render partial: "shared/visits/questions/boolean", locals: { question: presenter, f: f }
    end

    doc = Capybara.string(rendered)
    expect(doc).to have_css("input[type='hidden'][name$='[boolean_answer]'][value='']", visible: :all)
    expect(doc).not_to have_css(".yes-no-options input[type='radio']:checked")
    expect(doc).to have_css("span.clr-red", text: "*")
  end

  it "does not mark an optional question as required" do
    question = create(:reserve_question, location: :visit, answer_required: false)
    mock_reserve_answer(question, boolean: false)
    presenter = Visits::QuestionPresenter.new(question)

    FakeForm.fields_for(presenter) do |f|
      render partial: "shared/visits/questions/boolean", locals: { question: presenter, f: f }
    end

    expect(Capybara.string(rendered)).not_to have_css("span.clr-red")
  end
end
