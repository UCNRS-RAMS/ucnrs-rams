require "rails_helper"

RSpec.describe "projects/questions/_question.html.erb", type: :view do
  it "interpolates the values from a QuestionPresenter" do
    question_text = SecureRandom.uuid
    question = create(
      :reserve_question,
      :text_question,
      question: question_text,
      description: "Here is where you can learn more:",
      url_1: "https://lmgtfy.com",
      url_link_text_1: "Let Me Google That For You",
      url_2: "https://your-local.library",
      url_link_text_2: "Take a look!"
    )
    mock_reserve_answer(question, text: "Oh, ok")
    presenter = Projects::QuestionPresenter.new(question)

    render partial: "projects/questions/question", locals: { question: presenter }

    doc = Capybara.string(rendered)
    expect(doc).to have_content(question_text)
    expect(doc).to have_css("li[data-value-projection-projected-value='Oh, ok']")
    expect(doc).to have_css(".description:contains('Here is where you can learn more:')")
    expect(doc).to have_css(".description a[href='https://lmgtfy.com']:contains('Let Me Google That For You')")
    expect(doc).to have_css(".description a[href='https://your-local.library']:contains('Take a look!')")
  end
end
