class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @presenter = HomeIndexPresenter.new(
      invoices: Invoice.fake,
      news_articles: NewsArticle.fake,
      user: current_user,
    )
  end
end
