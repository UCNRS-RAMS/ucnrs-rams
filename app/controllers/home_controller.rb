class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @presenter = HomeIndexPresenter.new(
      invoices: Invoice.fake,
      news_articles: NewsArticle.fake,
      user: current_user,
      visit_filter: visit_filter,
      visit_page: visit_page_number,
    )
  end

  private

  def visit_filter
    params[:visit_filter]
  end

  def visit_page_number
    params[:visit_page]
  end
end
