require "rails_helper"

RSpec.describe Unauthenticated::SessionsController, type: :request do
  let(:password) { "Password1" }

  def sign_in_with_form(user)
    post user_session_path, params: { user: { email: user.email, password: password } }
  end

  describe "/users/sign_in" do
    context "when signing in lands" do
      it "returns a user to the page they asked for before signing in" do
        user = create(:user, :confirmed, password: password)

        get projects_path(page: 2)
        expect(response).to redirect_to(new_user_session_path)

        sign_in_with_form(user)

        expect(response).to redirect_to(projects_path(page: 2, format: :html))
      end

      it "sends a user who asked for the site root to their dashboard" do
        user = create(:user, :confirmed, password: password)

        get root_path
        sign_in_with_form(user)

        expect(response).to redirect_to(dashboard_index_path(format: :html))
      end

      it "sends them to their dashboard when they came to sign in directly" do
        user = create(:user, :confirmed, password: password)

        sign_in_with_form(user)

        expect(response).to redirect_to(dashboard_index_path(format: :html))
      end

      it "keeps the requested page for after a missing profile is completed" do
        user = build(:user, :confirmed, password: password, terms_accepted_at: nil).tap { |u| u.save!(validate: false) }

        get projects_path
        sign_in_with_form(user)
        expect(response).to redirect_to(edit_user_registration_path)

        put user_registration_path, params: { user: { terms_accepted_at: "1", institution_id: user.institution_id } }

        expect(response).to redirect_to(projects_path(format: :html))
      end
    end
  end
end
