require "rails_helper"

RSpec.describe Unauthenticated::RegistrationsController, type: :request do
  describe "/users/sign_up" do
    it "uses the focused layout, with no links into the rest of RAMS" do
      create(:country, name: "United States")

      get new_user_registration_path

      doc = Capybara.string(response.body)
      expect(doc).to have_css("body.focused")
      expect(doc).to have_no_css("header a[href='#{reserves_path}']")
      expect(doc).to have_no_css("header a[href='#{dashboard_index_path}']")
      expect(doc).to have_no_css("header form[action='#{destroy_user_session_path}']")
    end

    it "do not use the focused layout on other public pages" do
      get reserves_path

      doc = Capybara.string(response.body)
      expect(doc).to have_no_css("body.focused")
      expect(doc).to have_css("header a[href='#{reserves_path}']")
    end
  end

  describe "PUT /users" do
    it "still requires accepted terms when the skip flag is submitted, make sure users cannot bypass the terms acceptance" do
      user = build(:user, :confirmed, terms_accepted_at: nil)
      user.save!(validate: false)
      sign_in(user)

      put user_registration_path,
        params: { user: { skip_terms_accepted_validation: "1", institution_id: user.institution_id } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(user.reload.terms_accepted_at).to be_nil
    end
  end
end
