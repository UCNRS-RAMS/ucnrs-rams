class Countries::StatesController < ApplicationController
  def index
    @presenter = Countries::StatesIndexPresenter.new(country: country)

    render layout: false
  end

  private

  def country
    Country.find_by(id: params[:country_id])
  end
end
