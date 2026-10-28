require "rails_helper"

RSpec.describe "Home Index" do
  let(:email) { "test@test.test" }
  let(:password) { "Password1" }

  describe "home calendar" do
    it "show visit calendar", js: true do
      create(:user, :confirmed, email: email, password: password)

      flow = HomeIndexFlow.new(page)

      flow.visit_sign_in_page
      flow.sign_in_as(email: email, password: password)
      expect(page).to have_no_css("input#user_password")
      flow.visit_home_index_page
      flow.dismiss_modal
      flow.click_calendar_button

      expect(flow).to be_on_home_index_page
      expect(flow).to have_calendar
    end

    it "display visit bars from visit start_date and end_date", js: true do
      user = create(:user, :confirmed, email: email, password: password)
      visit = create(:visit, user: user, starts_at: Time.current, ends_at: 1.week.from_now)
      visit_date_range = (visit.starts_at.to_date..visit.ends_at.to_date)
        .map { |date| date.strftime("%Y-%m-%d") }

      flow = HomeIndexFlow.new(page)

      flow.visit_sign_in_page
      flow.sign_in_as(email: email, password: password)
      expect(page).to have_no_css("input#user_password")
      flow.visit_home_index_page
      flow.dismiss_modal
      flow.click_calendar_button

      expect(flow).to be_on_home_index_page
      expect(flow).to have_calendar

      visit_date_range.each do |date|
        expect(flow).to have_visit_bar(date)
      end
      expect(flow).to have_visit_status_bar(visit.starts_at.strftime("%Y-%m-%d"), visit.status)
    end
  end
end
