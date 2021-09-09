class StatesController < ApplicationController
  def index
    @states = State
      .in_country(country)
      .alphabetical_by_name

    render json: @states
  end

  private

  def country
    Country.find_by(id: params[:country_id])
  end
end
