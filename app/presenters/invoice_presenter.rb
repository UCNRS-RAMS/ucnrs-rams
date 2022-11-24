class InvoicePresenter
  def initialize(invoice)
    @invoice = invoice
  end

  attr_reader :invoice

  delegate :id, :modify_number, :amenity_visits, :invoice_payments, :status, :balance_due, to: :invoice
  delegate :id, to: :visit, prefix: true
  delegate :reserve_id, to: :visit
  delegate :reserve_name, to: :visit

  def amenities_total
    "$#{value(invoice_total)}"
  end

  def amount
    "$ #{value(balance_due)}"
  end

  private
  delegate :visit, :invoice_total, to: :invoice, private: true

  def value(num)
    "%0.2f" % [num]
  end
end
