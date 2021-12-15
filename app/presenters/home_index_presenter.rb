class HomeIndexPresenter
  DEFAULT_LIMIT_FOR_INDEX = 10.freeze

  def initialize(user:, page: nil, invoices:, news_articles:)
    @invoices = invoices
    @news_articles = news_articles
    @user = user
    @page = page || 1
  end

  attr_reader :user, :page

  def visits
    visit_scope.map do |visit|
      VisitPresenter.new(visit)
    end
  end

  def visit_scope
    Visit
      .visit_requests_for_user(user: user)
      .order(starts_at: :desc)
      .page(page)
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
end
