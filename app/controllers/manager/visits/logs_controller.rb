class Manager::Visits::LogsController < Manager::ApplicationController
  before_action :authenticate_user!
  before_action :confirm_manager!

  def show
    @presenter = Manager::Visits::LogPresenter.new(record: log, reserve: current_reserve)
  end

  private

  def log
    @log ||= Log.find(params[:id])
  end
end
