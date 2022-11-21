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

  describe "#balance" do
    it "return amenity_visits total of invoice" do
      amenity_visit = create(:amenity_visit, invoice_id: invoice.id, rate: 10)
      invoice_payment = create(:invoice_payment, invoice: invoice, user: user, amount: 1000)
      presenter = Manager::Invoices::InvoiceEditPresenter.new(visit: visit, invoice: invoice, form: InvoiceForm.new(invoice: invoice, params: { visit_id: visit.id }, editing: true))
      amenity_visit_total = format("%0.2f", invoice.amenity_visits.sum(&:subtotal)).to_i
      payments_amount_total = format("%0.2f", invoice.invoice_payments.pluck(:amount).sum).to_i
      output = "-$ #{(amenity_visit_total - payments_amount_total).abs}"

      expect(presenter.balance).to eq output
    end
  end
end
