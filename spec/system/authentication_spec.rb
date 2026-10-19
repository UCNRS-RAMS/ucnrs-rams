require "rails_helper"

RSpec.describe "Authentication", type: :system, js: true do
  describe "when signed out" do
    let(:email) { "test@test.test" }
    let(:password) { "Password1" }

    it "the user gets redirected to sign in when going to the homepage", js: true do
      user = create(:user, :confirmed, email: email, password: password)
      flow = AuthenticationFlow.new(page)

      flow.visit_homepage
      expect(flow).to be_on_sign_in_page

      flow.sign_in_as(email: email, password: password)
      expect(flow).to be_signed_in
    end

    it "allows the user to change their password to something new", js: true do
      user = create(:user, :confirmed, email: email, password: password)
      flow = AuthenticationFlow.new(page)

      flow.visit_forgot_password_page
      expect(page).to be_axe_clean

      flow.reset_password_for(email)
      flow.follow_reset_password_email_link
      expect(page).to be_axe_clean

      flow.reset_password_to("Password2")
      expect(flow).to be_signed_in

      flow.visit_homepage
      flow.dismiss_modal # Necessary for now.
      flow.sign_out
      flow.sign_in_as(email: email, password: "Password2")
      expect(flow).to be_signed_in
    end
  end

  describe "when the email address is not confirmed" do
    let(:email) { "test@test.test" }
    let(:password) { "Password1" }

    it "sends the user to resend confirmation with their email filled in" do
      create(:user, email: email, password: password)
      flow = AuthenticationFlow.new(page)

      flow.visit_sign_in_page
      flow.sign_in_as(email: email, password: password)

      expect(page).to have_current_path(new_user_confirmation_path)
      expect(page).to have_content("Your email address hasn't been confirmed yet.")
      expect(page).to have_field("Email Address", with: email)
      expect(page).to be_axe_clean

      ActionMailer::Base.deliveries.clear
      click_button "Send Link"

      expect(flow).to be_on_sign_in_page
      expect(ActionMailer::Base.deliveries.flat_map(&:to)).to eq([ email ])
    end

    it "confirms and signs in a 'non completed' user who resets their password" do
      build(:user, email: email, password: password, terms_accepted_at: nil).save!(validate: false)
      flow = AuthenticationFlow.new(page)

      flow.visit_forgot_password_page
      flow.reset_password_for(email)
      flow.follow_reset_password_email_link

      page.fill_in("Create a New Password", with: "Password2")
      page.fill_in("Re-enter Password", with: "Password3")
      page.find("input[type='submit']").click
      expect(page).to have_content("Password confirmation doesn't match Password")

      flow.reset_password_to("Password2")
      expect(flow).to be_signed_in
    end

    it "links to resend confirmation from the sign in page" do
      flow = AuthenticationFlow.new(page)

      flow.visit_sign_in_page
      click_link "Didn't get a confirmation email?"

      expect(page).to have_current_path(new_user_confirmation_path)
      expect(page).to have_field("Email Address", with: "")
    end
  end

  describe "when signed in" do
    let(:email) { "test@test.test" }
    let(:password) { "Password1" }

    it "can sign the user out" do
      create(:user, :confirmed, email: email, password: password)
      flow = AuthenticationFlow.new(page)

      flow.visit_homepage
      flow.sign_in_as(email: email, password: password)
      expect(flow).to be_signed_in

      flow.visit_homepage
      flow.dismiss_modal
      flow.sign_out

      expect(flow).to be_on_sign_in_page
      expect(flow).to_not be_signed_in
    end
  end
end
