require "rails_helper"

RSpec.describe "Completing a profile after signing in", type: :system, js: true do
  it "asks for missing details, then lets the user carry on" do
    email = "test@test.test"
    password = "Password1"
    FactoryBot.build(
      :user,
      :confirmed,
      email: email,
      password: password,
      emergency_contact_full_name: nil,
      terms_accepted_at: nil,
    ).save!(validate: false)
    flow = AuthenticationFlow.new(page)

    flow.visit_sign_in_page
    flow.sign_in_as(email: email, password: password)

    expect(page).to have_current_path(edit_user_registration_path)
    expect(page).to have_content(I18n.t("profile_completion.required"))
    expect(page).to have_field("user[emergency_contact_full_name]", with: "")
    expect(page).to be_axe_clean.skipping(:"color-contrast")

    fill_in "user[emergency_contact_full_name]", with: "Cassian Andor"
    check "user_terms_accepted_at", allow_label_click: true
    find("form[action='#{user_registration_path}'] button[type='submit']").click

    expect(page).to have_current_path(dashboard_index_path(format: :html))
    expect(page).to have_content(I18n.t("devise.registrations.flash.updated"))
  end
end
