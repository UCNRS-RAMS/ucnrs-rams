class HomeIndexPresenter
  DEFAULT_LIMIT_FOR_INDEX = 10.freeze

  def initialize(user:, visit_page: nil, visit_filter:, invoices:, news_articles:)
    @invoices = invoices
    @news_articles = news_articles
    @user = user
    @visit_filter = visit_filter || nil
    @visit_page = visit_page || 1
    @visit_status_filter = filter_type == :status ? visit_filter : nil
    @visit_reserve_filter = filter_type == :reserve ? reserve_id : nil
  end

  attr_reader :visit_filter, :visit_status_filter, :visit_reserve_filter, :user, :visit_page

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
      .per(DEFAULT_LIMIT_FOR_INDEX)
      .includes(:reserve)
  end

  def invoices
    @invoices.map do |invoice|
      InvoicePresenter.new(invoice)
    end
  end

  def news_articles
    @news_articles.map do |news_article|
      NewsArticlePresenter.new(news_article)
    end
  end

  def selected?(option)
    option == visit_filter ? "selected" : ""
  end

  def filter_options
    Visit::STATUS_FILTERS
  end

  def visits_reserve_list
    Visit.reserve_list_for_user(user)
  end

  def filter_type
    if visit_filter.present? && visit_filter.split("_")[0] == "reserve"
      :reserve
    else
      :status
    end
  end

  def reserve_id
    visit_filter.split("_")[1]
  end
end
