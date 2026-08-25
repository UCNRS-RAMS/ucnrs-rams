class UsersController < ApplicationController
  before_action :authenticate_user!

  layout false

  def index
    @presenter = UsersIndexPresenter.new(query: query)
  end

  private

  def query
    params[:q]
  end
end
