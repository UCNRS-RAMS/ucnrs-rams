class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @presenter = HomeIndexPresenter.new(
      invoices: Invoice.fake,
      news_articles: NewsArticle.fake,
      user: current_user,
      page: page_number,
    )
  end

  private

  def page_number
    params[:page]
  end
end
