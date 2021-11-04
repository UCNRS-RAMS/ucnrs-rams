class Reserves::RulesAndRegulationsController < ApplicationController
  def show
    @page = Reserves::RulesAndRegulationsShowPresenter.new(
      reserve: reserve
    )
  end

  private

  def reserve_id
    params.permit(:reserve_id).require(:reserve_id)
  end

  def reserve
    Reserve.find(reserve_id)
  end
end
