require "rails_helper"

RSpec.describe "Manager Invoices Index" do
  describe "paginated invoices" do
    it "paginates invoices displaying 10 at a time", js: true do
      reserve = create(:reserve)
      user = create(:user, :confirmed, managed_reserves: [reserve])
      visit = create(:visit, reserve: reserve)
      25.times do |n|
        create(:invoice, visit: visit)
      end

      flow = Manager::InvoiceIndexFlow.new(page)
      sign_in(user)

      flow.visit_manager_invoice_index_page(reserve)
      expect(flow).to be_on_manager_invoice_index_page
      expect(flow).to have_active_invoices_tab
      expect(flow).to have_displayed_invoices(10)
      expect(flow).to have_pagination_link("next")
      expect(flow).to have_pagination_link("last")
      expect(flow).to have_selected_page_number_link(1)
      expect(flow).to have_page_number_link(2)
      expect(flow).to have_page_number_link(3)

      flow.go_to_last_page
      expect(flow).to have_displayed_invoices(5)
      expect(flow).to have_pagination_link("first")
      expect(flow).to have_pagination_link("prev")
      expect(flow).to have_page_number_link(1)
      expect(flow).to have_page_number_link(2)
      expect(flow).to have_selected_page_number_link(3)
    end
  end
end
