class Manager::Projects::LogsController < Manager::ApplicationController
  before_action :authenticate_user!
  before_action :confirm_current_reserve_manager!, unless: -> { super_admin? }

  def show
    @presenter = Manager::Projects::ActivityPresenter.new(
      record: log,
      reserve: current_reserve,
    )
  end

  private

  def log
    Log.find(params[:id])
  end
end
