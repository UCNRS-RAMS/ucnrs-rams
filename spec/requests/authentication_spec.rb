require "rails_helper"

RSpec.describe "Authentication", type: :request do
  let(:email) { "test@test.test" }
  let(:password) { "Password1" }

  describe "when signed out" do
    it "redirects the home page to sign in" do
      get "/home"

      expect(response).to redirect_to(new_user_session_path)
    end

    it "signs a confirmed user in and out" do
      create(:user, :confirmed, email: email, password: password)

      post "/users/sign_in", params: { user: { email: email, password: password } }

      expect(response).to redirect_to(dashboard_index_path(format: :html))
      get "/home"
      expect(response).to be_ok

      delete "/users/sign_out"

      get "/home"
      expect(response).to redirect_to(new_user_session_path)
    end

    it "rejects a wrong password" do
      create(:user, :confirmed, email: email, password: password)

      post "/users/sign_in", params: { user: { email: email, password: "wrong" } }

      get "/home"
      expect(response).to redirect_to(new_user_session_path)
    end

    it "resets the password from the emailed token" do
      user = create(:user, :confirmed, email: email, password: password)
      ActionMailer::Base.deliveries.clear

      post "/users/password", params: { user: { email: email } }

      delivery = ActionMailer::Base.deliveries.last
      expect(delivery).to be_present
      token = delivery.body.to_s[/reset_password_token=([\w-]+)/, 1]
      expect(token).to be_present

      put "/users/password", params: {
        user: {
          reset_password_token: token,
          password: "Password2",
          password_confirmation: "Password2"
        }
      }

      expect(response).to redirect_to(dashboard_index_path(format: :html))
      expect(flash[:notice]).to include("Your password has been changed successfully.")
      expect(user.reload.valid_password?("Password2")).to be(true)
    end
  end
end

RSpec.describe "Home", type: :request do
  describe "welcome modal" do
    it "displays only on the first visit after signing in" do
      user = create(:user, :confirmed)
      sign_in(user)

      get "/home"
      expect(Capybara.string(response.body)).to have_css("#modal-title", text: "Welcome to RAMS")

      get "/home"
      expect(Capybara.string(response.body)).to have_no_css("#modal-title", text: "Welcome to RAMS")
    end

    it "never displays for a reserve manager" do
      reserve = create(:reserve)
      user = create(:user, :confirmed, managed_reserves: [ reserve ])
      sign_in(user)

      get "/home"

      expect(Capybara.string(response.body)).to have_no_css("#modal-title", text: "Welcome to RAMS")
    end
  end

  describe "paginated visits" do
    it "displays ten visits per page" do
      user = create(:user, :confirmed)
      sign_in(user)
      25.times do
        visit = create(:visit, user: user, starts_at: Time.current, ends_at: 1.week.from_now)
        create(:user_visit, user: user, visit: visit)
      end

      get "/home"

      page = Capybara.string(response.body)
      expect(page).to have_css("tr.visit", count: 10)
      expect(page).to have_css("span.next")
      expect(page).to have_css("span.last")
      expect(page).to have_css("span.current", text: "1")
      expect(page).to have_css("span.page a", text: "2")
      expect(page).to have_css("span.page a", text: "3")

      get "/home", params: { visit_page: 3 }

      page = Capybara.string(response.body)
      expect(page).to have_css("tr.visit", count: 5)
      expect(page).to have_css("span.first")
      expect(page).to have_css("span.prev")
      expect(page).to have_css("span.current", text: "3")
    end
  end

  describe "visit calendar" do
    it "draws a bar for a visit and filters the calendar by status" do
      user = create(:user, :confirmed)
      sign_in(user)
      approved = create(:visit, user: user, status: :approved,
        starts_at: Time.current.beginning_of_month, ends_at: Time.current.end_of_month)
      create(:user_visit, user: user, visit: approved)

      get "/home/calendar", params: { start_date: Time.current.beginning_of_month.iso8601 }

      page = Capybara.string(response.body)
      expect(response).to be_ok
      expect(page).to have_css(".simple-calendar")
      expect(page).to have_css("a[href='#{visit_path(approved)}']")

      get "/home/calendar", params: {
        start_date: Time.current.beginning_of_month.iso8601,
        visit_filter: "incomplete"
      }

      page = Capybara.string(response.body)
      expect(page).to have_no_css("a[href='#{visit_path(approved)}']")
    end
  end
end
