require "rails_helper"

RSpec.describe InvoicePaymentPresenter do
  let(:payment) { create(:invoice_payment, invoice: create(:invoice), paid_on: "31-10-1999") }

  describe "delegations" do
    subject { InvoicePaymentPresenter.new(payment) }
    it { is_expected.to delegate_missing_methods_to(:payment) }
  end

  describe "#paid_on" do
    it "return date when payment for invoice happen" do
      presenter = InvoicePaymentPresenter.new(payment)
      output = "Oct 31, 1999"

      expect(presenter.paid_on).to eq output
    end
  end
end
