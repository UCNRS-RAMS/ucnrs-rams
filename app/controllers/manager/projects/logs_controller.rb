class Manager::Projects::LogsController < Manager::ApplicationController
  before_action :authenticate_user!
  before_action :confirm_current_reserve_manager!, unless: -> { super_admin? }

  def show
    @presenter = Manager::Projects::ActivityPresenter.new(record: Log.find(params[:id]), reserve: current_reserve)
  end
end
