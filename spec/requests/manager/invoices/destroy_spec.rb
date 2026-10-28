require "rails_helper"

RSpec.describe Manager::InvoicesController, type: :request do
  let(:reserve) { create(:reserve) }
  let(:visit) { create(:visit, reserve: reserve) }
  let(:invoice) { create(:invoice, visit: visit) }
  let(:user) { create(:user, :confirmed) }

  before do
    create(:reserve_personnel, user: user, reserve: reserve)
    sign_in(user)
  end

  describe "DELETE /manager/reserves/:reserve_id/invoices/:id" do
    it "deletes the invoice and redirects to the new invoice page for its visit" do
      invoice

      expect do
        delete manager_reserve_invoice_path(reserve, invoice)
      end.to change(Invoice, :count).by(-1)

      expect(response).to redirect_to(new_manager_reserve_visit_invoice_path(reserve, visit))
      expect(Invoice.find_by(id: invoice.id)).to be_nil
    end
  end
end
