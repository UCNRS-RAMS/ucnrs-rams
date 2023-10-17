class Manager::DashboardController < Manager::ApplicationController
  before_action :authenticate_user!
  before_action :confirm_current_reserve_manager!, unless: -> { super_admin? }

  layout "manager"

  def show
    @presenter = Manager::DashboardShowPresenter.new(
      reserve: current_reserve,
      partial_name: params[:partial_name]
    )

    session[:dashboard] = :dashboard
  end
end
