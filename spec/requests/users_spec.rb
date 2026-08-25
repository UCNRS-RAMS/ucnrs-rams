require "rails_helper"

RSpec.describe UsersController, type: :request do
  describe "GET /users" do
    it "redirects to sign in when the user is not authenticated" do
      create(:user, :confirmed, first_name: "Scrooge", last_name: "McDuck")

      get "/users", params: { q: "McDuck" }

      expect(response).to redirect_to(new_user_session_url)
    end

    it "renders matching users when user is authenticated" do
      sign_in(create(:user, :confirmed))
      scrooge = create(:user, :confirmed, first_name: "Scrooge", last_name: "McDuck")

      get "/users", params: { q: "McDuck" }

      doc = Capybara.string(response.body)
      expect(response).to be_ok
      expect(doc).to have_css("li[data-autocomplete-value='#{scrooge.id}']")
    end

    it "renders no results when there is no query" do
      sign_in(create(:user, :confirmed))
      create(:user, :confirmed, first_name: "Scrooge", last_name: "McDuck")

      get "/users"

      doc = Capybara.string(response.body)
      expect(response).to be_ok
      expect(doc).to have_css("li[aria-disabled='true']", text: "No Results")
    end

    it "renders no results when the query is shorter than the current minimum length of 2" do
      sign_in(create(:user, :confirmed))
      create(:user, :confirmed, first_name: "Scrooge", last_name: "McDuck")

      get "/users", params: { q: "M" }

      doc = Capybara.string(response.body)
      expect(response).to be_ok
      expect(doc).to have_css("li[aria-disabled='true']", text: "No Results")
    end
  end
end
