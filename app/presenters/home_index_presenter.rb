class HomeIndexPresenter
  def initialize(visit_requests:, invoices:, news_articles:)
    @visit_requests = visit_requests
    @invoices = invoices
    @news_articles = news_articles
  end

  def visit_requests
    @visit_requests.map do |visit_request|
      VisitRequestPresenter.new(visit_request)
    end
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
