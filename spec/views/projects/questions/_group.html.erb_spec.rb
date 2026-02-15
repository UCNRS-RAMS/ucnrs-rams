require "rails_helper"

RSpec.describe "projects/questions/_group.html.erb", type: :view do
  it "renders the interpolatd values" do
    render partial: "projects/questions/group", locals: { title: "Title!", questions: [] }

    doc = Capybara.string(rendered)
    expect(doc).to have_css("h2:contains('Title!')")
    expect(doc).to have_css("ul.title_questions")
  end

  it "renders a partial for each question passed in" do
    render partial: "projects/questions/group", locals: { title: "", questions: [
      double(render_values: { inline: "<li>One!</li>" }),
      double(render_values: { inline: "<li>Two!</li>" }),
      double(render_values: { inline: "<li>Three!</li>" }),
    ]}

    doc = Capybara.string(rendered)
    expect(doc).to have_css("li:contains('One!') + li:contains('Two!') + li:contains('Three!')")
  end
end
