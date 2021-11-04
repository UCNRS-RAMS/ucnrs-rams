class Reserves::WaiversController < ApplicationController
  def index
    @page = Reserves::WaiversIndexPresenter.new(
      reserve_waivers: reserve_waivers
    )
  end

  private

  def reserve_id
    params.permit(:reserve_id).require(:reserve_id)
  end

  def reserve_waivers
    Reserve.find(reserve_id).waivers
  end
end
