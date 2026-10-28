require "rails_helper"

RSpec.describe Manager::Invoices::PaymentsController, type: :request do
  let(:reserve) { create(:reserve) }
  let(:visit) { create(:visit, reserve: reserve) }
  let(:invoice) { create(:invoice, visit: visit) }
  let(:user) { create(:user, :confirmed) }

  before do
    create(:reserve_personnel, user: user, reserve: reserve)
    sign_in(user)
  end

  describe "GET /manager/reserves/:reserve_id/invoices/:invoice_id/payments/new" do
    it "renders the record payment modal" do
      get new_manager_reserve_invoice_payment_path(reserve, invoice), as: :turbo_stream

      expect(response).to be_ok

      page = Capybara.string(response.body)
      expect(page).to have_css("turbo-stream[action='update'][target='modal-content']")
      expect(response.body).to include("name=\"invoice_payment[amount]\"")
      expect(response.body).to include("name=\"invoice_payment[paid_on]\"")
      expect(response.body).to include("Record Payment")
    end
  end

  describe "POST /manager/reserves/:reserve_id/invoices/:invoice_id/payments" do
    it "records the payment and redirects to the invoice edit page" do
      expect do
        post manager_reserve_invoice_payments_path(reserve, invoice), params: {
          invoice_payment: {
            invoice_id: invoice.id,
            amount: "8",
            paid_on: "2022-10-20",
            notes: "Paid in cash"
          }
        }, as: :turbo_stream
      end.to change(InvoicePayment, :count).by(1)

      expect(response).to redirect_to(edit_manager_reserve_invoice_path(reserve, invoice))

      payment = InvoicePayment.last
      expect(payment.invoice_id).to eq(invoice.id)
      expect(payment.user_id).to eq(user.id)
      expect(payment.amount).to eq(8)
      expect(invoice.reload.balance_due).to eq(-8)
    end

    it "re-renders the modal without persisting an invalid payment" do
      expect do
        post manager_reserve_invoice_payments_path(reserve, invoice), params: {
          invoice_payment: {
            invoice_id: invoice.id,
            amount: "",
            paid_on: ""
          }
        }, as: :turbo_stream
      end.not_to change(InvoicePayment, :count)

      expect(response).to be_ok

      page = Capybara.string(response.body)
      expect(page).to have_css("turbo-stream[action='update'][target='modal-content']")
      expect(response.body).to include("invoice_payment[amount]")
      expect(invoice.reload.balance_due).to eq(0)
    end
  end
end
