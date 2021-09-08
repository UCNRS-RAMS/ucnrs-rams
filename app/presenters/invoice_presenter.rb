class InvoicePresenter
  include ActionView::Helpers::NumberHelper

  def initialize(invoice)
    @invoice = invoice
  end

  attr_reader :invoice

  delegate :id, :status, to: :invoice

  def requested_reserve_name
    invoice.name
  end

  def amount
    number_to_currency(invoice.amount / 100.0)
  end
end
