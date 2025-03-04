class Visits::ReservesController < ApplicationController
  before_action :authenticate_user!
  layout false

  def index
    @presenter = Visits::ReservesPresenter.new(
      reserve_id: reserve_id,
      project_type: project_type,
      project_id: project_id,
    )
  end

  private

  def project_id
    params[:project_id]
  end

  def project_type
    params[:project_type]
  end

  def reserve_id
    params[:reserve_id]
  end
end
