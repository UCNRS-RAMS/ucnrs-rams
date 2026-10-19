require "rails_helper"

RSpec.describe Manager::UsersController, type: :request do
  describe "editing a user who has not accepted the terms" do
    it "does not offer the terms checkbox to the manager" do
      reserve = create(:reserve)
      manager = create(:user, :confirmed)
      create(:reserve_personnel, user: manager, reserve: reserve)
      user = build(:user, terms_accepted_at: nil)
      user.save!(validate: false)
      sign_in(manager)

      get edit_manager_reserve_user_path(reserve, user)

      doc = Capybara.string(response.body)
      expect(doc).to have_field("user[first_name]")
      expect(doc).to have_no_field("user[terms_accepted_at]")
    end

    it "saves the manager's changes without accepting the terms for the user" do
      reserve = create(:reserve)
      manager = create(:user, :confirmed)
      create(:reserve_personnel, user: manager, reserve: reserve)
      user = build(:user, terms_accepted_at: nil)
      user.save!(validate: false)
      sign_in(manager)

      patch manager_reserve_user_path(reserve, user),
        params: { user: { first_name: "Jyn", institution_id: user.institution_id } }

      expect(response).to have_http_status(:ok)
      expect(user.reload).to have_attributes(first_name: "Jyn", terms_accepted_at: nil)
    end
  end
end
