require "rails_helper"

RSpec.describe "Authentication", type: :feature do
  describe "when signed out" do
    let(:name) { "name" }
    let(:email) { "test@test.test" }
    let(:password) { "1234567890" }

    it "allows the user to sign up" do
      flow = AuthenticationFlow.new(page)
      flow.visit_sign_up_page
      flow.fill_out_account_creation_form(
        email: email,
        password: password,
      )

      flow.confirm_email
      expect(flow).to have_confirmed_email_is_valid

      flow.sign_in_as(email: email, password: password)
      expect(flow).to be_signed_in
    end

    it "means the user gets redirected to sign in when going to the homepage" do
      user = FactoryBot.create(:user, :confirmed, email: email, password: password)
      flow = AuthenticationFlow.new(page)
      flow.visit_homepage
      expect(flow).to be_on_sign_in_page

      flow.sign_in_as(email: email, password: password)
      expect(flow).to be_signed_in
    end
  end
end
