class HomeIndexPresenter
  def initialize(user:, invoices:, news_articles:)
    @invoices = invoices
    @news_articles = news_articles
    @user = user
  end

  attr_reader :user

  def visits
    visit_scope.map do |visit|
      VisitPresenter.new(visit)
    end
  end

  def visit_scope
    Visit
      .visit_requests_for_user(user: user)
      .order(starts_at: :desc)
      .limit(Visit::DEFAULT_LIMIT_FOR_INDEX)
      .includes(:reserve, :user_visits)
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
