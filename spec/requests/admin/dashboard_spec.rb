require "rails_helper"

RSpec.describe Admin::DashboardController, type: :request do
  describe "GET /admin" do
    it "renders the admin dashboard for an admin user" do
      user = create(:user, :confirmed, admin: true)
      sign_in(user)

      get "/admin"

      expect(response).to be_ok
    end

    it "blocks non-admin users" do
      user = create(:user, :confirmed)
      sign_in(user)

      get "/admin"

      expect(response).not_to be_ok
    end
  end
end
