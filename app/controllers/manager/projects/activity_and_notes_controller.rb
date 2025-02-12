class Manager::Projects::ActivityAndNotesController < Manager::ApplicationController
  before_action :authenticate_user!
  before_action :confirm_current_reserve_manager!, unless: -> { super_admin? }
  before_action :is_administrator!, unless: -> { super_admin? }, only: [:create]

  layout "manager"

  def index
    @presenter = Manager::Projects::ActivityAndNotesIndexPresenter.new(
      project: project,
      logs_page: params[:logs_page],
      notes_page: params[:notes_page],
      reserve: current_reserve,
    )

    @project_summary_presenter = Manager::ProjectShowPresenter.new(
      project: project,
      reserve: current_reserve,
      current_user: current_user,
    )
  end

  def show
    @presenter = Manager::Projects::ActivityPresenter.new(
      record: Log.find(params[:id]),
      reserve: current_reserve,
    )
  end

  def create
    @note = project.reserve_notes.new(note_params)
    if @note.save
      redirect_to manager_reserve_project_activity_and_notes_path(current_reserve, project)

    else
      @presenter = Manager::Projects::ActivityAndNotesIndexPresenter.new(project: project)
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
