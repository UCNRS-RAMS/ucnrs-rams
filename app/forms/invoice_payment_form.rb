# frozen_string_literal: true

class InvoicePaymentForm
  include Rails.application.routes.url_helpers
  include ActiveModel::Model

  def model_name
    ActiveModel::Name.new(InvoicePayment)
  end

  def initialize(params: {}, editing: false)
    @editing = editing
    @invoice_payment = InvoicePayment.find_by(id: params[:id]) || InvoicePayment.new
    assign(params)
  end

  attr_reader :invoice_payment, :editing

  delegate_missing_to :invoice_payment

  def save
    invoice_payment.save if validate
  end

  private

  def assign(params)
    params.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def validate
    invoice_payment.valid?
  end
end
