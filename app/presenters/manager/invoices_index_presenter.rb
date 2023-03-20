class Manager::InvoicesIndexPresenter
  DEFAULT_LIMIT_FOR_INDEX = 10

  SORT_OPTIONS = {
    "Date Created" => :created_recent_first,
    "Amount" => :sort_by_amount,
    "Balance Due" => :sort_by_balance_due,
    "Invoice Number" => :sort_by_invoice_number
  }

  def initialize(reserve: nil, user: nil, page: 1, filter: nil)
    @page = page
    @reserve = reserve
    @filter = InvoiceFilter.new(filter, reserve)
    @user = user
  end

  attr_reader :reserve, :page, :filter, :user

  def invoices
    invoice_scope.map do |invoice|
      InvoicePresenter.new(invoice)
    end
  end

  def invoice_scope
    Invoice
    .with_invoices_at_reserve(reserves)
    .searching_term(invoice_search_filter)
    .for_status(invoice_status_filter)
    .having_between_time_for(
      date_range_option: :visit_date_range,
      date_start: visit_date_begin_filter,
      date_end: visit_date_end_filter
    )
    .having_between_time_for(
      date_range_option: :invoiced_on,
      date_start: invoice_date_begin_filter,
      date_end: invoice_date_end_filter
    )
    .sort_using(sort_by_filter)
    .page(page)
    .per(DEFAULT_LIMIT_FOR_INDEX)
  end

  def sort_by_options
    SORT_OPTIONS
  end

  def invoice_status_options
    {
      I18n.t("manager.invoices.index.all") => nil,
      I18n.t("manager.invoices.index.paid") => :paid,
      I18n.t("manager.invoices.index.pending") => :due,
    }
  end

  def reserve_options
    user
     .managed_reserves
     .select(:id, :name)
     .order(:name)
     .each
     .inject({ "All" => nil }) { |memo, reserve| memo.merge!(reserve.name => reserve.id) }
  end

  private

  delegate :reserve_filter,
    :invoice_status_filter,
    :invoice_search_filter,
    :invoice_type_filter,
    :visit_date_end_filter,
    :visit_date_begin_filter,
    :reserve_filter,
    :date_range_type_filter,
    :sort_by_filter,
    :invoice_date_end_filter,
    :invoice_date_begin_filter,
    to: :filter

  delegate :present?, to: :filter, prefix: true

  def reserves
    return reserve_filter if reserve_filter.present? && reserve != "all"
    user.managed_reserve_ids
  end
end
