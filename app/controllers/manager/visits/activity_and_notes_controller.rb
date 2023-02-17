class Manager::Visits::ActivityAndNotesController < Manager::ApplicationController
  before_action :authenticate_user!
  before_action :confirm_manager!
  before_action :is_administrator_or_accountant!, only: [:create]

  def index
    @presenter = Manager::Visits::ActivityAndNotesIndexPresenter.new(
      visit: visit, logs_page: params[:logs_page], notes_page: params[:notes_page])
  end

  def show
    @presenter = Manager::Visits::LogPresenter.new(record: log, reserve: current_reserve)
  end

  def create
    @note = visit.reserve_notes.new(note_params)
    if @note.save
      redirect_to manager_reserve_visit_activity_and_notes_path(current_reserve, visit)
    else
      @presenter = Manager::Visits::ActivityAndNotesIndexPresenter.new(visit: visit)
      render :index, status: :unprocessable_entity
    end
  end

  private

  def visit
    Visit.find(visit_id)
  end

  def visit_id
    params.permit(:visit_id).require(:visit_id)
  end

  def note_params
    params.require(:reserve_note).permit(:note).tap do |note_params|
      note_params[:user_id] = current_user.id
      note_params[:reserve_id] = current_reserve.id
    end
  end

  def log
    @log ||= Log.find(params[:id])
  end
end
