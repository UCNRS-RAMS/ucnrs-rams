class ReserveInputsController < ApplicationController
  before_action :authenticate_user!

  def show
    @page = ReserveInputsPresenter.new(reserve)
    render layout: false
  end

  private

  def reserve
    Reserve.find(params[:reserve_id])
  end
end
