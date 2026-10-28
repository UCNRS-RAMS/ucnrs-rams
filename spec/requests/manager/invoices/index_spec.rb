require "rails_helper"

RSpec.describe Manager::InvoicesController, type: :request do
  let(:reserve) { create(:reserve) }
  let(:visit) { create(:visit, reserve: reserve) }
  let(:user) { create(:user, :confirmed) }

  before do
    create(:reserve_personnel, user: user, reserve: reserve)
    create_list(:invoice, 25, visit: visit)
    sign_in(user)
  end

  describe "GET /manager/reserves/:reserve_id/invoices" do
    it "paginates the invoices ten at a time" do
      get manager_reserve_invoices_path(reserve)

      expect(response).to be_ok

      page = Capybara.string(response.body)
      expect(page).to have_css("tr.invoice", count: 10)
      expect(page).to have_css("nav.pagination span.page.current", text: "1")
      expect(page).to have_css("nav.pagination span.next a[rel='next']")
      expect(page).to have_css("nav.pagination span.last a")
      expect(page).to have_css("nav.pagination span.page a", text: "3")
    end

    it "shows the remaining invoices on the last page" do
      get manager_reserve_invoices_path(reserve), params: { page: 3 }

      expect(response).to be_ok

      page = Capybara.string(response.body)
      expect(page).to have_css("tr.invoice", count: 5)
      expect(page).to have_css("nav.pagination span.page.current", text: "3")
      expect(page).to have_css("nav.pagination span.first a")
      expect(page).to have_css("nav.pagination span.prev a[rel='prev']")
      expect(page).to have_no_css("nav.pagination span.next a")
    end
  end
end
