# frozen_string_literal: true

class Manager::Invoices::InvoiceEditPresenter < Manager::Invoices::InvoicesFormPresenter
  def initialize(visit:, invoice: nil, form: nil)
    super(visit: visit, form: form)
    @invoice = invoice || Invoice.new
  end

  attr_reader :invoice, :visit

  delegate :id, to: :invoice, prefix: true

  def title
    I18n.t("manager.invoices.edit.invoice", id: id, version: modify_number)
  end

  def invoice_payments
    @invoice_payments ||= @invoice&.invoice_payments.map { |payment| InvoicePaymentPresenter.new(payment) }
  end

  def payments_total
    invoice_payments.pluck(:amount).sum
  end

  def balance
    amenities_total - payments_total
  end

  def balance_class
    balance >= 0 ? "positive_balance" : "negative_balance"
  end

  private

  delegate :modify_number, :id, to: :invoice
end
