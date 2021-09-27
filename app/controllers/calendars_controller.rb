class CalendarsController < ApplicationController
  def show; end

  private

  def reserve_id
    params.permit(:reserve_id).require(:reserve_id)
  end
end
