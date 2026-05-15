# frozen_string_literal: true

class Manager::Visits::InvoicesIndexPresenter
  include ActionView::Helpers::NumberHelper

  DEFAULT_PAGE_LIMIT = 10

  def initialize(visit:, form: nil, invoice_filter: nil, user: nil)
    @invoice_filter = invoice_filter
    @visit = visit
    @form = form || InvoiceForm.new
    @user = user
  end

  attr_reader :visit, :invoice_filter, :user, :form
  delegate_missing_to :visit

  delegate :amenities_total, to: :form

  def invoice_filter_options
    Invoice::OPTIONS_FILTERS
  end

  def selected_invoices
    if invoice_filter == "project_invoices"
      project_invoices
    else
      visit_invoices
    end
  end

  def reserve_manager?(_reserve)
    user.admin_or_manage_reserve?(visit.reserve)
  end

  def invoice_selected(option)
    option == invoice_filter ? "selected" : ""
  end

  def visit_total
    number_to_currency amenity_visits_total
  end

  def invoiced
    number_to_currency invoices_total
  end

  def paid
    number_to_currency(payments_total * -1)
  end

  def total_balance
    number_to_currency(amenity_visits_total - payments_total)
  end

  def amenity_visit_presenters
    form.amenity_visits&.map do |amenity_visit|
      AmenityVisitPresenter.new(amenity_visit)
    end
  end

  private

  def value(num)
    format("%0.2f", num)
  end

  def amenity_visits_total
    amenity_visits.sum(&:subtotal)
  end

  def invoices_total
    invoices.sum(&:invoice_total)
  end

  def payments_total
    invoices.sum(&:payments_amount_total)
  end

  def visit_invoices
    invoices.map do |invoice|
      InvoicePresenter.new(invoice)
    end
  end

  def project_invoices
    Invoice.by_project(visit.project_id).map do |invoice|
      InvoicePresenter.new(invoice)
    end
  end
end
