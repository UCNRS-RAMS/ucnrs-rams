require "rails_helper"

RSpec.describe "Completing a profile after signing in", type: :request do
  let(:password) { "Password1" }

  it "sends a user with missing details to their profile when they sign in" do
    user = build(:user, :confirmed, password: password, emergency_contact_full_name: nil, terms_accepted_at: nil)
    user.save!(validate: false)

    post user_session_path, params: { user: { email: user.email, password: password } }

    expect(response).to redirect_to(edit_user_registration_path)
    expect(flash[:notice]).to eq(I18n.t("profile_completion.required"))
  end

  it "takes them on to their dashboard once the profile is saved" do
    user = build(:user, :confirmed, password: password, emergency_contact_full_name: nil, terms_accepted_at: nil)
    user.save!(validate: false)
    post user_session_path, params: { user: { email: user.email, password: password } }

    put user_registration_path,
      params: { user: { emergency_contact_full_name: "Louisa Strentzel", terms_accepted_at: "1", institution_id: user.institution_id } }

    expect(response).to redirect_to(dashboard_index_path(format: :html))
    expect(user.reload.profile_incomplete?).to be(false)
  end

  it "leaves only sign out on the profile page (focused layout)" do
    user = build(:user, :confirmed, emergency_contact_full_name: nil, terms_accepted_at: nil)
    user.save!(validate: false)
    sign_in(user)

    get edit_user_registration_path

    doc = Capybara.string(response.body)
    expect(doc).to have_css("body.focused")
    expect(doc).to have_no_css("header a[href='#{projects_path}']")
    expect(doc).to have_no_css("header a[href='#{dashboard_index_path}']")
    expect(doc).to have_no_css("main a[href='#{root_path}']")
    expect(doc).to have_css("header form[action='#{destroy_user_session_path}']")
  end

  it "keeps the usual links on the profile page once details are complete" do
    sign_in(create(:user, :confirmed))

    get edit_user_registration_path

    doc = Capybara.string(response.body)
    expect(doc).to have_css("header a[href='#{projects_path}']")
    expect(doc).to have_css("main a[href='#{root_path}']")
  end

  it "does not stop them using other pages after sign in" do
    user = build(:user, :confirmed, password: password, emergency_contact_full_name: nil, terms_accepted_at: nil)
    user.save!(validate: false)
    post user_session_path, params: { user: { email: user.email, password: password } }

    get projects_path

    expect(response).not_to redirect_to(edit_user_registration_path)
  end

  it "sends a user with a complete profile straight to their dashboard" do
    user = create(:user, :confirmed, password: password)

    post user_session_path, params: { user: { email: user.email, password: password } }

    expect(response).to redirect_to(dashboard_index_path(format: :html))
  end
end
