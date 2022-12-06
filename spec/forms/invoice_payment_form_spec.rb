# frozen_string_literal: true

require "rails_helper"

RSpec.describe InvoicePaymentForm, type: :model do

  describe "delegations" do
    it { is_expected.to delegate_missing_methods_to(:invoice_payment) }
  end

  describe "initializing" do
    it "makes a new empty InvoicePaymentForm" do
      form = InvoicePaymentForm.new

      expect(form.invoice_payment).to have_attributes(
        id: nil,
        invoice_id: nil,
        user_id: nil,
        amount: nil,
        paid_on: nil,
        payment_type: nil,
        notes: nil,
        payor: nil,
      )
    end

    it "makes a new InvoicePaymentForm from params" do
      params = {
        invoice_id: "20519",
        user_id: "44650",
        amount: "8",
        paid_on: "2022-11-19",
        notes: "look great",
      }
      form = InvoicePaymentForm.new(params: params)

      expect(form.invoice_payment).to have_attributes(
        invoice_id: 20519,
        user_id: 44650,
        amount: 0.8e1,
        notes: params[:notes],
      )
    end
  end

  describe "#save" do
    it "saves the invoice_payment if there are no errors" do
      user = create(:user, :confirmed)
      invoice = create(:invoice)
      params = {
        invoice_id: invoice.id,
        user_id: user.id,
        amount: "8",
        paid_on: "2022-11-19",
        notes: "look great",
      }
      form = InvoicePaymentForm.new(params: params)

      result = form.save

      expect(result).to be_truthy
      expect(form.invoice_payment).to have_attributes(amount: 0.8e1, notes: "look great")
    end

    it "makes sure errors are visible when save fails" do
      form = InvoicePaymentForm.new

      result = form.save

      expect(result).to be_falsy
      expect(form.invoice_payment).to_not be_persisted
      expect(form.invoice_payment.errors).to be_present
    end
  end
end
