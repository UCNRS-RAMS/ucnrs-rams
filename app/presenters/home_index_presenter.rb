class HomeIndexPresenter
  VISIT_LIMIT_FOR_INDEX = 10.freeze
  INVOICE_LIMIT_FOR_INDEX = 5.freeze

  def initialize(user:, visit_page: nil,invoice_page: nil, visit_filter: nil, invoice_filter: nil, news_articles: nil)
    @news_articles = news_articles
    @user = user
    @visit_filter = visit_filter
    @visit_page = visit_page || 1
    @invoice_filter = invoice_filter
    @invoice_page = invoice_page || 1
    @invoice_status_filter = filter_type(invoice_filter) == :status ? invoice_filter : nil
    @invoice_reserve_filter = filter_type(invoice_filter) == :reserve ? reserve_id(invoice_filter) : nil
    @visit_status_filter = filter_type(visit_filter) == :status ? visit_filter : nil
    @visit_reserve_filter = filter_type(visit_filter) == :reserve ? reserve_id(visit_filter) : nil
  end

  attr_reader :visit_filter, :visit_status_filter, :visit_reserve_filter, :user, :visit_page, :invoice_page, :invoice_filter, :invoice_reserve_filter, :invoice_status_filter

  def visits
    visit_scope.map do |visit|
      VisitPresenter.new(visit)
    end
  end

  def visit_scope
    Visit
      .visit_requests_for_user(user)
      .ordered_by_visit_date
      .for_status(visit_status_filter)
      .by_reserve(visit_reserve_filter)
      .page(visit_page)
      .per(VISIT_LIMIT_FOR_INDEX)
      .includes(:reserve)
  end

  def invoice_scope
    user.invoices
      .recent_first
      .by_reserve(invoice_reserve_filter)
      .for_status(invoice_status_filter)
      .page(invoice_page)
      .per(INVOICE_LIMIT_FOR_INDEX)
  end

  def invoices
    invoice_scope.map do |invoice|
      InvoicePresenter.new(invoice)
    end
  end

  def news_articles
    @news_articles.map do |news_article|
      NewsArticlePresenter.new(news_article)
    end
  end

  def visit_selected(option)
    option == visit_filter ? "selected" : ""
  end

  def invoice_selected(option)
    option == invoice_filter ? "selected" : ""
  end

  def visit_filter_options
    Visit::STATUS_FILTERS
  end

  def invoice_filter_options
    Invoice::STATUS_FILTERS
  end

  def visits_reserve_list
    Visit.reserve_list_for_user(user)
  end

  def invoice_reserve_list
    user.invoices.map do |invoice|
      [invoice.visit.reserve_name, invoice.visit.reserve_id]
    end.to_h
  end

  private
  def filter_type(filter)
    if filter.present? && filter.split("_")[0] == "reserve"
      :reserve
    else
      :status
    end
  end

  def reserve_id(filter)
    filter.split("_")[1].to_i
  end
end
