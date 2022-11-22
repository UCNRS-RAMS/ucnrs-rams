# frozen_string_literal: true

class InvoicePaymentForm
  include ActiveModel::Model

  def model_name
    ActiveModel::Name.new(InvoicePayment)
  end

  def initialize(params: {})
    @invoice_payment = InvoicePayment.find_by(id: params[:id]) || InvoicePayment.new(params)
  end

  attr_reader :invoice_payment

  delegate :invoice_id, to: :invoice_payment

  def save
    invoice_payment.save if validate
  end

  private

  def validate
    invoice_payment.valid?
  end
end
