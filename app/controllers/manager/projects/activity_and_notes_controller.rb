class Manager::Projects::ActivityAndNotesController < Manager::ManagerController
  before_action :authenticate_user!
  before_action :confirm_reserve_manager!
  before_action :project, only: [:index, :create]
  before_action :is_administrator!, only: [:create]

  def index
    @presenter = Manager::Projects::ActivityAndNotesIndexPresenter.new(
      project: @project, logs_page: params[:logs_page], notes_page: params[:notes_page])
  end

  def show
    @presenter = Manager::Projects::ActivityPresenter.new(record: Log.find(params[:id]))
  end

  def create
    @note = @project.reserve_notes.new(note_params)
    if @note.save
      redirect_to manager_reserve_project_activity_and_notes_path(current_reserve, @project)
    else
      @presenter = Manager::Projects::ActivityAndNotesIndexPresenter.new(project: @project)
      render :index, status: :unprocessable_entity
    end
  end

  private

  def project
    @project ||= Project.find(project_id)
  end

  def project_id
    params.permit(:project_id).require(:project_id)
  end

  def note_params
    params.require(:reserve_note).permit(:note).tap do |note_params|
      note_params[:user_id] = current_user.id
      note_params[:reserve_id] = current_reserve.id
    end
  end
end
