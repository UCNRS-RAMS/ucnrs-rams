class Visits::UnitsController < ApplicationController

  def index
    render json: {
      data: helpers.num_of_units(
        params[:arrive]&.to_time,
        params[:departs]&.to_time,
        params[:unit]&.strip
      )
    },
    status: :ok
  end
end
