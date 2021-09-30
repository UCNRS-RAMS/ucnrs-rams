class VisitsController < ApplicationController
  before_action :authenticate_user!

  def new
    @page = VisitsNewPresenter.new
  end
end
