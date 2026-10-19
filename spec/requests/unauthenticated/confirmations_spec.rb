require "rails_helper"

RSpec.describe Unauthenticated::ConfirmationsController, type: :request do
  let(:email) { "unconfirmed@test.test" }
  let(:password) { "Password1" }

  describe "confirmations logic" do
    context "when signing in before confirming an email address" do
      it "sends an unconfirmed user with the right password to resend confirmation, email filled in" do
        create(:user, email: email, password: password)

        post user_session_path, params: { user: { email: email, password: password } }

        expect(response).to redirect_to(new_user_confirmation_path)

        follow_redirect!

        expect(response.body).to include("Your email address hasn&#39;t been confirmed yet")
        expect(response.body).to include(%(value="#{email}"))
      end

      it "keeps the standard password error for an unconfirmed user with the wrong password" do
        create(:user, email: email, password: password)

        post user_session_path, params: { user: { email: email, password: "Wrong1234" } }

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("Invalid email or password.")
        expect(response.body).not_to include("been confirmed")
      end

      it "resends the confirmation email from the resend page" do
        create(:user, email: email, password: password)
        ActionMailer::Base.deliveries.clear

        post user_confirmation_path, params: { user: { email: email } }

        expect(ActionMailer::Base.deliveries.flat_map(&:to)).to eq([ email ])
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
