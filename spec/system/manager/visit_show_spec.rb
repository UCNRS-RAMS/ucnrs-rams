require "rails_helper"

RSpec.describe "Manager Visit Show" do
  let(:user) { create(:user, :confirmed) }
  let!(:reserve) { create(:reserve, name: "Test Reserve") }
  let!(:reserve_personnel) { create(:reserve_personnel, user: user, reserve: reserve) }
  let(:visit) { create(:visit, reserve: reserve) }

  # The only browser coverage kept for this page: the guest name field is an
  # autocomplete fed by a JSON endpoint, and the selected suggestion is posted
  # back over Turbo. Everything else this page did was moved to
  # spec/requests/manager/visits/*.rb.
  describe "when on add guest form", js: true do
    it "adds user to the visitors list when a user is selected from the suggestions list" do
      flow = Manager::VisitShowVisitorTabFlow.new(page: page, visit_id: visit.id, reserve_id: reserve.id)

      sign_in(user)
      flow.visit_show_page
      flow.click_on_vistors_tab

      flow.click_on_add_individual
      flow.set_guest
      flow.select_option

      flow.click_add_visitor

      expect(page).to have_css(".user-visit")
    end
  end
end
