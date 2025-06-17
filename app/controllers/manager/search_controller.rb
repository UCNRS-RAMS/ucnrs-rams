class Manager::SearchController < Manager::ApplicationController
  before_action :authenticate_user!
  before_action :confirm_current_reserve_manager!, unless: -> { super_admin? }

  layout "manager"

  def index
    @presenter = Manager::SearchIndexPresenter.new(
      reserve: current_reserve,
      page: page_number,
      filter: filter,
    )

    filter&.dig(:date_range_type)
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
        :user_type,
        :institution_type,
        :exclude_reserve_institution,
      )
    end
  end
end
