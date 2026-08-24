require "rails_helper"

RSpec.describe "Creating an institution from the profile form", type: :system do
  it "fills the institution field without reloading the page", js: true do
    country = create(:country, name: "United States")
    state = create(:state, name: "California", country: country)
    user = create(:user, :confirmed,
                 institution: create(:institution, country: country, state: state))

    sign_in(user)
    visit "/users/edit"

    expect(page).not_to have_field("user[institution]", with: "Bodega Marine Laboratory")

    click_link "Create a New Institution."

    within "#modal" do
      fill_in "institution[name]", with: "Bodega Marine Laboratory"
      fill_in "institution[city]", with: "Bodega Bay"
      select "University of California", from: "institution[institution_type]"
      find("#institution_country_id option[value='#{country.id}']").select_option
      click_button "Create"
    end

    expect(page).to have_field("user[institution]", with: "Bodega Marine Laboratory")

    institution = Institution.find_by(name: "Bodega Marine Laboratory")
    expect(page).to have_field("user[institution_id]", with: institution.id.to_s, type: :hidden)
    expect(page).not_to have_css("#modal.visible")
  end
end
