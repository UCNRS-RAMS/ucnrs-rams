require "rails_helper"

RSpec.describe  Manager::Invoices::InvoiceEditPresenter do
  let(:project) { create(:project) }
  let(:reserve) { create(:reserve) }
  let(:visit) { create(:visit, reserve: reserve, project: project) }
  let(:invoice) { create(:invoice, visit: visit) }
  let(:user) { create(:user, :confirmed) }

  describe "delegations" do
    subject { Manager::Invoices::InvoiceEditPresenter.new(visit: visit, invoice: invoice, form: InvoiceForm.new(invoice: invoice, params: { visit_id: visit.id })) }
    it { is_expected.to delegate_method(:id).to(:invoice).with_prefix(true) }
  end

  describe "#title" do
    it "return invoice title with invoice id and version" do
      presenter = Manager::Invoices::InvoiceEditPresenter.new(visit: visit, invoice: invoice, form: InvoiceForm.new(invoice: invoice, params: { visit_id: visit.id }))
      output = "Edit Invoice #{invoice.id}-#{invoice.modify_number}"

      expect(presenter.title).to eq output
    end
  end

  describe "#invoice_payments" do
    context "when invoice has payments" do
      let!(:invoice_payment1) { create(:invoice_payment, invoice: invoice) }
      let!(:invoice_payment2) { create(:invoice_payment, invoice: invoice) }
      let!(:presenter) {
        Manager::Invoices::InvoiceEditPresenter.new(
          visit: visit,
          invoice: invoice,
          form: InvoiceForm.new(invoice: invoice, params: { visit_id: visit.id }))
      }

      it "returns an array of InvoicePaymentPresenter objects" do
        invoice_payments = presenter.invoice_payments
        expect(invoice_payments).to be_an(Array)
        expect(invoice_payments).to all(be_an(InvoicePaymentPresenter))
      end
    end

    context "when invoice has no payments" do
      it "returns an empty array" do
        invoice_payments = invoice.invoice_payments
        expect(invoice_payments).to be_empty
      end
    end
  end
end
