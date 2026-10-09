class Manager::Dashboard::CalendarController < Manager::ApplicationController
  before_action :authenticate_user!
  before_action :confirm_current_reserve_manager!, unless: -> { super_admin? }

  layout "manager"

  def show
    @presenter = Manager::Dashboard::CalendarShowPresenter.new(
      reserve: current_reserve,
      filter: ReserveCalendarFilter.from_params(params),
    )

    session[:dashboard] = :calendar
  end
end
