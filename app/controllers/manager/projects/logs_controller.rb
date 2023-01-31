class Manager::Projects::LogsController < Manager::ManagerController
  before_action :authenticate_user!
  before_action :confirm_reserve_manager!

  def show
    @presenter = Manager::Projects::ActivityPresenter.new(record: Log.find(params[:id]), reserve: current_reserve)
  end
end
