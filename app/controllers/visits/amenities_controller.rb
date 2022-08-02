class Visits::AmenitiesController < ApplicationController
  include ApplicationHelper
  before_action :authenticate_user!
  layout false

  def index
    @presenter = Visits::AmenitiesPresenter.new(
      reserve_id: reserve_id,
      user: current_user,
    )
  end

  def subtotal
    render json: { data: num_of_units(params[:arrive].to_time, params[:departs].to_time, params[:unit].strip) }, status: :ok 
  end

  private

  def reserve_id
    params.permit(:reserve_id).require(:reserve_id)
  end
end
