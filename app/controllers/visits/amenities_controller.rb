class Visits::AmenitiesController < ApplicationController
  before_action :authenticate_user!
  layout false

  def index
    @page = Visits::AmenitiesPresenter.new(reserve_id: reserve_id)
  end

  private

  def reserve_id
    params.permit(:reserve_id).require(:reserve_id)
  end
end
