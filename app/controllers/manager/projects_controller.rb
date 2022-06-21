class Manager::ProjectsController < ApplicationController
  before_action :authenticate_user!
  layout "manager"

  def show
    @presenter = Manager::ProjectShowPresenter.new(project)
  end

  def edit
    form = ProjectForm.new(user: current_user, params: { id: project.id })
    @presenter = ProjectFormPresenter.new(
      user: current_user,
      current_step: 1,
      project_type: project.project_type,
      form: form,
    )
  end

  def update
    form = ProjectForm.new(user: current_user, params: project_params.merge(id: project.id))
    if form.save
      redirect_to project_team_memberships_path(form.project, format: :html)
    else
      @presenter = ProjectFormPresenter.new(
        user: current_user,
        current_step: 1,
        project_type: form.project_type,
        form: form,
      )
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def project
    @project ||= Project.find_by(id: project_id, reserve_id: reserve_id)
    return @project if @project

    flash[:alert] = "Cannot find that project."
    redirect_to root_path
  end

  def project_id
    params.permit(:id).require(:id)
  end

  def reserve_id
    params.permit(:reserve_id).require(:reserve_id)
  end
end
