class UsersController < ApplicationController
  layout false

  def index
    @presenter = UsersIndexPresenter.new(query: query)
  end

  private

  def query
    params[:q]
  end
end
