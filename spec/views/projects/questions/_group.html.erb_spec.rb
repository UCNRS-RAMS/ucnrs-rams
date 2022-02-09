require "rails_helper"

RSpec.describe "projects/questions/_group.html.erb", type: :view do
  it "renders the interpolatd values" do
    render partial: "projects/questions/group", locals: { title: "Title!", questions: [] }

    doc = Capybara.string(rendered)
    expect(doc).to have_css("h2:contains('Title!')")
    expect(doc).to have_css("ul.title_questions")
  end

  it "renders a partial for each question passed in" do
    stub_template(
      "projects/questions/_one.html.erb" => "<li>One!</li>",
      "projects/questions/_two.html.erb" => "<li>Two!</li>",
      "projects/questions/_three.html.erb" => "<li>Three!</li>",
    )

    render partial: "projects/questions/group", locals: { title: "", questions: [
      OpenStruct.new(render_values: { partial: "one" }),
      OpenStruct.new(render_values: { partial:  "two" }),
      OpenStruct.new(render_values: { partial:  "three" }),
    ]}

    doc = Capybara.string(rendered)
    expect(doc).to have_css("li:contains('One!') + li:contains('Two!') + li:contains('Three!')")
  end
end
