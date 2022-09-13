class Manager::Dashboard::VisitsController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_reserve_manager!
  layout "manager"

  def index
    @presenter = Manager::Dashboard::VisitsIndexPresenter.new(
      reserve: current_reserve,
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
        :visit_search,
        :visit_status,
        :report_access,
        :sort_by,
        :visit_project_type,
        :date_range_type,
        :date_begin,
        :date_end,
        :reserve,
        :amenity,
      )
    end
  end
end
