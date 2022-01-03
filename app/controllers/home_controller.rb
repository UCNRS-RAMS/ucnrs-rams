class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @presenter = HomeIndexPresenter.new(
      visit_requests: VisitRequest.fake,
      invoices: Invoice.fake,
      news_articles: NewsArticle.fake,
    )
  end
end
