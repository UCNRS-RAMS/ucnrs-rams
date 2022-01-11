class Reserves::AddendumsController < ApplicationController
  def index
    @presenter = Reserves::AddendumsIndexPresenter.new(
      reserve: reserve,
      addendums: addendums,
    )
  end

  private

  def reserve_id
    params.permit(:reserve_id).require(:reserve_id)
  end

  def reserve
    Reserve.find(reserve_id)
  end

  def addendums
    reserve&.addendums
  end
end
