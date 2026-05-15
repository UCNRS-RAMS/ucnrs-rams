require "rails_helper"

RSpec.describe "app/views/visits/amenities/_amenity.html.erb", type: :view do
  it "shows comments and rates in a 'learn more' section" do
    user = create(:user, :confirmed)
    amenity = create(:amenity, comment: "This is a comment")
    amenity_rate_category = create(:amenity_rate_category, state_university: true)
    rate = create(:amenity_rate, amenity: amenity, rate: 0.01, amenity_rate_category: amenity_rate_category)
    selected_rate = create(:amenity_rate, amenity: amenity, rate: 12.50,  amenity_rate_category: amenity_rate_category)
    form = Visits::AmenityForm.new(params: { amenity_rate_id: selected_rate.id })
    presenter = Visits::AmenityPresenter.new(amenity, form: [form])


    FakeForm.fields_for(form) do |form|
      # commenting out.  Why assign the item to itself?  Is there some reason?
      # form.object = form.object
      render partial: "visits/amenities/amenity",
        locals: { presenter: presenter, form: form, group_label: "Home", forms: presenter.form }
    end

    doc = Capybara.string(rendered)
    expect(doc).to have_css(".comment-and-rates p", text: "$0.01 per facility/per day")
    expect(doc).to have_css(".comment-and-rates p", text: "$12.50 per facility/per day")
    expect(doc).to have_css("[data-controller='toggle'] .comment-and-rates[data-toggle-target='toggle'][data-toggle-class='showing']")
    expect(doc).to have_css("[data-controller='toggle'] a[data-toggle-target='toggle'][data-toggle-class='showing'][data-action='click->toggle#toggle']", text: I18n.t("amenities.amenity.more_info"))
    expect(doc).to have_css("[data-controller='toggle'] a[data-toggle-target='toggle'][data-toggle-class='showing'][data-action='click->toggle#toggle']", text: I18n.t("amenities.amenity.less_info"))
  end
end
