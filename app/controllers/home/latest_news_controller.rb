class Home::LatestNewsController < ApplicationController
  before_action :authenticate_user!

  def index
    @presenter = Home::LatestNews::IndexPresenter.new(HttpGetter)
  end
end
