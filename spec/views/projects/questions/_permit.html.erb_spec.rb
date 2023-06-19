require "rails_helper"

RSpec.describe "projects/questions/_permit.html.erb", type: :view do
  it "interpolates the values from a PermitPresenter" do
    question_text = SecureRandom.uuid
    permit = create(
      :permit,
      question: question_text,
      description: "Here is where you can learn more:",
      url1: "https://lmgtfy.com",
      url1_description: "Let Me Google That For You",
      url2: "https://your-local.library",
      url2_description: "Take a look!"
    )
    presenter = Projects::PermitPresenter.new(permit: permit)

    render partial: "projects/questions/permit", locals: { permit: presenter }

    doc = Capybara.string(rendered)
    expect(doc).to have_content(question_text)
    expect(doc).to have_css("li[data-value-projection-projected-value='0']")
    expect(doc).to have_css(".description:contains('Here is where you can learn more:')")
    expect(doc).to have_css(".description a[href='https://lmgtfy.com']:contains('Let Me Google That For You')")
    expect(doc).to have_css(".description a[href='https://your-local.library']:contains('Take a look!')")
    expect(doc).to have_css(".answers input[type='radio'][value='1']")
    expect(doc).to have_css(".answers input[type='radio'][value='0'][checked='checked']")
  end
end

