class Manager::Reports::FlexController < Manager::ApplicationController
  include ProjectFundingQuery
  include TableauUsageQuery

  before_action :authenticate_user!
  before_action :confirm_current_reserve_manager!, unless: -> { super_admin? }

  layout "manager"

  FISCAL_MONTH_BEGIN = 7
  FISCAL_DAY_BEGIN = 1
  FISCAL_MONTH_END = 6
  FISCAL_DAY_END = 30

  $FLEX_TYPE_ARRAY = []
  $RESERVES_ARRAY = []
  $FLEX_ALL_RESERVES_ARRAY = []

  def index
    case filter[:project_status]
    when "funding" then data = project_funding(reserve: filter[:reserve], begin_date: filter&.dig(:date_begin).presence, end_date: filter&.dig(:date_end).presence)
    when "tableau_usage" then data = tableau_usage(filter&.dig(:date_begin).presence, filter&.dig(:date_end).presence)
    end

    @presenter = Manager::Reports::FlexIndexPresenter.new(
      filter: filter,
      data: data,
    )
  end

  def filter
    if params[:filter].present?
      params.require(:filter).permit(
        :project_search,
        :project_status,
        :sort_by,
        :project_type,
        :date_range_type,
        :date_begin,
        :date_end,
        :reserve,
      )
    end
  end
end
