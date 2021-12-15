require "rails_helper"

RSpec.describe "Home Index" do
  describe "paginated visits" do
    it "paginates visits displaying 10 at a time", js: true do
      user = create(:user, :confirmed)
      25.times do |n|
        visit = create(:visit, user: user, starts_at: Time.current, ends_at: 1.week.from_now)
        user_visit = create(:user_visit, user: user, visit: visit)

        visit.user_visits.first.id
      end

      flow = HomeIndexFlow.new(page)
      sign_in(user)

      flow.visit_home_index_page
      flow.dismiss_modal
      expect(flow).to be_on_home_index_page
      expect(flow).to have_active_my_visits_tab
      expect(flow).to have_displayed_visits(10)
      expect(flow).to have_pagination_link("next")
      expect(flow).to have_pagination_link("last")
      expect(flow).to have_selected_page_number_link(1)
      expect(flow).to have_page_number_link(2)
      expect(flow).to have_page_number_link(3)
      expect(page).to be_axe_clean

      flow.go_to_page(3)
      expect(flow).to have_displayed_visits(5)
      expect(flow).to have_pagination_link("first")
      expect(flow).to have_pagination_link("prev")
      expect(flow).to have_page_number_link(1)
      expect(flow).to have_page_number_link(2)
      expect(flow).to have_selected_page_number_link(3)
    end
  end
end
