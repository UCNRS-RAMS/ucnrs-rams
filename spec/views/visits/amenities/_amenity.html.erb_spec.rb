require "rails_helper"

RSpec.describe "app/views/visits/amenities/_amenity.html.erb", type: :view do
  it "shows comments and rates in a 'learn more' section" do
    amenity = create(:amenity, comment: "This is a comment")
    rate1 = create(:amenity_rate, amenity: amenity, rate: 0.01)
    rate2 = create(:amenity_rate, amenity: amenity, rate: 12.50)
    presenter = Visits::AmenityPresenter.new(amenity)

    FakeForm.fields_for(AmenityForm.new) do |form|
      render partial: "visits/amenities/amenity",
        locals: { presenter: presenter, form: form }
    end

    doc = Capybara.string(rendered)
    expect(doc).to have_css(".comment-and-rates p", text: amenity.comment)
    expect(doc).to have_css(".comment-and-rates p", text: "$0.01 per facility/per day")
    expect(doc).to have_css(".comment-and-rates p", text: "$12.50 per facility/per day")
    expect(doc).to have_css("[data-controller='toggle'] .comment-and-rates[data-toggle-target='toggle'][data-toggle-class='showing']")
    expect(doc).to have_css("[data-controller='toggle'] a[data-toggle-target='toggle'][data-toggle-class='showing'][data-action='click->toggle#toggle']", text: I18n.t("amenities.amenity.more_info"))
    expect(doc).to have_css("[data-controller='toggle'] a[data-toggle-target='toggle'][data-toggle-class='showing'][data-action='click->toggle#toggle']", text: I18n.t("amenities.amenity.less_info"))
  end
end
