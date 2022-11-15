class Manager::InstitutionsController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_reserve_manager!
  layout "manager"

  def index
    @presenter = Manager::InstitutionsIndexPresenter.new(
      page: page_number,
      filter: filter,
    )
  end

  private
 
  def page_number
    params[:page]
  end

  def filter
    if params[:filter].present?
      params.require(:filter).permit(
        :institution_search,
        :institution_sort_by,
        :institution_country,
        :institution_type,
      )
    end
  end
end
