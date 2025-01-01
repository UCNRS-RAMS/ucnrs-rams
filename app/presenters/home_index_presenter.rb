class HomeIndexPresenter
  include Rails.application.routes.url_helpers

  VISIT_LIMIT_FOR_INDEX = 10.freeze
  INVOICE_LIMIT_FOR_INDEX = 10.freeze

  STATUS_FILTERS = {
    "visit_date" => nil,
    "approved" => "approved",
    "in_review" => "in_review",
    "cancelled" => "cancelled",
    "incomplete" => "incomplete",
  }.freeze

  ORDER_FILTERS = {
    "submit date" => "order_submitted_at"
  }

  def initialize(user:, visit_page: nil, invoice_page: nil, visit_filter: nil,
    invoice_filter: nil, news_articles: nil, partial: "visits")

    @news_articles = news_articles
    @user = user
    @visit_filter = visit_filter
    @visit_page = visit_page || 1
    @invoice_filter = invoice_filter
    @invoice_page = invoice_page || 1
    @invoice_status_filter = filter_type(invoice_filter) == :status ? invoice_filter : nil
    @invoice_reserve_filter = filter_type(invoice_filter) == :reserve ? filter_value(invoice_filter) : nil
    @visit_status_filter = filter_type(visit_filter) == :status ? visit_filter : nil
    @visit_reserve_filter = filter_type(visit_filter) == :reserve ? filter_value(visit_filter) : nil
    @visit_order_filter = filter_type(visit_filter) == :order ? filter_value(visit_filter) : nil
    @partial_name = partial || "visits_section"
  end

  attr_reader :visit_filter,
    :visit_status_filter,
    :visit_reserve_filter,
    :visit_order_filter,
    :user,
    :visit_page,
    :invoice_page,
    :invoice_filter,
    :invoice_reserve_filter,
    :invoice_status_filter,
    :partial_name

  def visits
    visit_scope.map do |visit|
      VisitPresenter.new(visit)
    end
  end

  def visit_scope
    Visit
      .visit_requests_for_user(user)
      .ordered_by(visit_order_filter)
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
      .includes(visit: :reserve)
  end

  def invoices
    invoice_scope.map do |invoice|
      InvoicePresenter.new(invoice)
    end
  end

  def list_button_class
    "active"
  end

  def calendar_button_class
    "inactive"
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
    STATUS_FILTERS
  end

  def visit_order_filter_options
    ORDER_FILTERS
  end

  def invoice_filter_options
    {
      I18n.t("home.index.recent_invoices") => nil,
      I18n.t("home.index.paid") => :paid,
      I18n.t("home.index.balance_due") => :due,
    }
  end

  def visits_reserve_list
    Visit.reserve_list_for_user(user)
  end

  def invoice_reserve_list
    user
      .invoices
      .includes(visit: :reserve)
      .map { |invoice| [invoice.visit.reserve_name, invoice.visit.reserve_id] }
      .to_h
  end

  private

  def filter_type(filter)
    if filter&.split("_").try(:first) == "reserve"
      :reserve
    elsif filter&.split("_").try(:first) == "order"
      :order
    else
      :status
    end
  end

  def filter_value(filter)
    filter&.split("_").try(:second)
  end
end
