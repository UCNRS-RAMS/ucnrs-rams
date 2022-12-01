class InvoicePresenter
  include Rails.application.routes.url_helpers

  def initialize(invoice)
    @invoice = invoice
  end

  attr_reader :invoice

  delegate :id, :modify_number, :amenity_visits, :invoice_payments, :status, :balance_due, to: :invoice
  delegate :id, to: :visit, prefix: true
  delegate :reserve_id, :reserve, to: :visit
  delegate :reserve_name, to: :visit

  def invoice_id
    "#{id}-#{modify_number}"
  end

  def invoiced_on
    invoice.invoiced_on.strftime("%b %d, %Y")
  end

  def amenity_visit_dates
    DateRangePresenter.value(start_date: amenity_visits.earliest_arrives_date, end_date: amenity_visits.latest_departs_date) if amenity_visits.present?
  end

  def manager_show_path
    manager_reserve_visit_invoice_path(reserve_id: reserve_id, visit_id: visit_id, id: id)
  end

  def invoice_status
    balance_due > 0 ? "pending" : "paid"
  end

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
