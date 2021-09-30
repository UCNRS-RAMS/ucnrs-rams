class AmenitiesController < ApplicationController
  before_action :authenticate_user!

  def index
    @page = AmenitiesIndexPresenter.new(for_reserve: reserve_id)
    render layout: false
  end

  private

  def reserve_id
    params.permit(:reserve_id).require(:reserve_id)
  end
end
