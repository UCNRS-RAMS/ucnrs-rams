require "rails_helper"

RSpec.describe "Admin::NewFeatures", type: :request do
  describe "GET /admin/new_features" do
    it "lists new features in a table" do
      NewFeature.create!(title: "Ooh Shiny!")
      sign_in(create(:user, :confirmed, admin: true))

      get admin_new_features_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("<table", "Ooh Shiny!")
    end
  end

  describe "DELETE /admin/new_features/:id" do
    it "deletes the new feature for an admin" do
      admin = create(:user, :confirmed, admin: true)
      new_feature = NewFeature.create!(title: "Ooh Shiny!")
      sign_in(admin)

      expect { delete admin_new_feature_path(new_feature) }.to change(NewFeature, :count).by(-1)

      expect(response).to redirect_to(admin_new_features_path)
    end

    it "does not delete the new feature for a non-admin" do
      new_feature = NewFeature.create!(title: "Ooh Shiny!")
      sign_in(create(:user, :confirmed))

      expect { delete admin_new_feature_path(new_feature) }.not_to change(NewFeature, :count)
    end
  end
end
