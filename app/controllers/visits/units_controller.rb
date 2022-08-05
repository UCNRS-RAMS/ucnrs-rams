class Visits::UnitsController < ApplicationController
  include ApplicationHelper
  def index
    render json: { data: num_of_units(params[:arrive]&.to_time, params[:departs]&.to_time, params[:unit]&.strip) }, status: :ok
  end
end
