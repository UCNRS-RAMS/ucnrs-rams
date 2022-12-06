# frozen_string_literal: true

class Manager::Invoices::InvoiceEditPresenter < Manager::Invoices::InvoicesFormPresenter
  def initialize(visit:, invoice: nil, form: nil)
    super(visit: visit, form: form)
    @invoice = invoice || Invoice.new
    @invoice_payments = @invoice&.invoice_payments
  end

  attr_reader :invoice_payments, :invoice

  delegate :id, to: :invoice, prefix: true

  def title
    I18n.t("manager.invoices.edit.invoice", id: id, version: modify_number)
  end

  def balance
    I18n.t("manager.invoices.edit.balance", balance: (amenity_visit_total.to_i - payments_amount_total).abs)
  end

  private 

  def value(num)
    format("%0.2f", num)
  end

  def payments_amount_total
    value(invoice_payments.pluck(:amount).sum).to_i
  end

  def amenity_visit_total
    "#{value(invoice.amenity_visits.sum(&:subtotal))}"
  end

  delegate :modify_number, :id, to: :invoice, private: true
end
