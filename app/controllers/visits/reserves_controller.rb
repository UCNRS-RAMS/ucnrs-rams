class Visits::ReservesController < ApplicationController
  before_action :authenticate_user!
  layout false

  def index
    @page = Visits::ReservesPresenter.new(
      reserve_id: reserve_id,
      project_type: project_type,
    )
  end

  private

  def project_type
    params[:project_type]
  end

  def reserve_id
    params[:reserve_id]
  end
end
