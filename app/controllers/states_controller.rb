class StatesController < ApplicationController
  def index
    @page = StatesIndexPresenter.new(country: country)

    render layout: false
  end

  private

  def country
    Country.find_by(id: params[:country_id])
  end
end
