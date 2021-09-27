class RulesAndRegulationsController < ApplicationController
  def show
    @page = RulesAndRegulationsShowPresenter.new(
      reserve: Reserve.find(reserve_id)
    )
  end

  private

  def reserve_id
    params.permit(:reserve_id).require(:reserve_id)
  end
end
