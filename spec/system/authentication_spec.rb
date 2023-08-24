require "rails_helper"

RSpec.describe "Authentication", type: :system, js: true do
  describe "when signed out" do
    let(:email) { "test@test.test" }
    let(:password) { "Password1" }

    it "means the user gets redirected to sign in when going to the homepage", js: true do
      user = FactoryBot.create(:user, :confirmed, email: email, password: password)
      flow = AuthenticationFlow.new(page)

      flow.visit_homepage
      expect(flow).to be_on_sign_in_page

      flow.sign_in_as(email: email, password: password)
      expect(flow).to be_signed_in
    end

    it "allows the user to change their password to something new", js: true do
      user = FactoryBot.create(:user, :confirmed, email: email, password: password)
      flow = AuthenticationFlow.new(page)

      flow.visit_forgot_password_page
      expect(page).to be_axe_clean.skipping(:"color-contrast")

      flow.reset_password_for(email)
      flow.follow_reset_password_email_link
      expect(page).to be_axe_clean.skipping(:"color-contrast")

      flow.reset_password_to("Password2")
      expect(flow).to be_signed_in

      flow.visit_homepage
      flow.dismiss_modal # Necessary for now.
      flow.sign_out
      flow.sign_in_as(email: email, password: "Password2")
      expect(flow).to be_signed_in
    end
  end

  describe "when signed in" do
    let(:email) { "test@test.test" }
    let(:password) { "Password1" }

    it "can sign the user out" do
      user = FactoryBot.create(:user, :confirmed, email: email, password: password)
      flow = AuthenticationFlow.new(page)

      flow.visit_homepage
      flow.sign_in_as(email: email, password: password)
      expect(flow).to be_signed_in

      flow.visit_homepage
      flow.dismiss_modal
      flow.sign_out
      # expect(flow).to_not be_signed_in  # Doesn't work after turbo
      expect(page).to_not have_css("body.home")

      flow.visit_homepage
      expect(flow).to_not be_signed_in
    end
  end
end
