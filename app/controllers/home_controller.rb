class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @presenter = HomeIndexPresenter.new(
      news_articles: NewsArticle.fake,
      user: current_user,
      visit_filter: visit_filter,
      visit_page: visit_page_number,
      invoice_filter: invoice_filter,
      invoice_page: invoice_page_number,
      partial: params[:partial_name]
    )

    if !session[:welcome].nil? || current_user.managed_reserves.present?
      @display_welcome_modal = false
    else
      session[:welcome] = true
      @display_welcome_modal = true
    end
  end

  private

  def visit_filter
    params[:visit_filter]
  end

  def visit_page_number
    params[:visit_page]
  end

  def invoice_filter
    params[:invoice_filter]
  end

  def invoice_page_number
    params[:invoice_page]
  end
end
