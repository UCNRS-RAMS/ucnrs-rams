class Reserves::AddendumsController < ApplicationController
  def index
    @page = Reserves::AddendumsIndexPresenter.new(
      addendums: addendums
    )
  end

  private

  def reserve_id
    params.permit(:reserve_id).require(:reserve_id)
  end

  def addendums
    Reserve.find(reserve_id).addendums
  end
end
