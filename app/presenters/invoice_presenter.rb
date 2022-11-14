class InvoicePresenter
  include ActionView::Helpers::NumberHelper

  def initialize(invoice)
    @invoice = invoice
  end

  attr_reader :invoice

  delegate :id, :status, :amenity_visits, to: :invoice

  def amenities_total
    "$#{value(amenity_visits.sum(&:subtotal))}"
  end

  def requested_reserve_name
    invoice.name
  end

  def amount
    number_to_currency(invoice.amount / 100.0)
  end

  private

  def value(num)
    "%0.2f" % [num]
  end
end
