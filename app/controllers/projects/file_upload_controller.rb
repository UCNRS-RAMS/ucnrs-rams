class Projects::FileUploadController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user

  def update
    form = ProjectForm.new(
      user: current_user, 
      params: project_params.merge(id: project.id), 
      file_index: params[:file_index],
    )
    if form.save
      @presenter = Projects::QuestionsIndexPresenter.new(
        current_step: 3,
        project: project,
      )
      flash.now[:notice] = "File has been uploaded"
      render :update
    else
      @presenter = Projects::QuestionsIndexPresenter.new(
        current_step: 3,
        project: project,
      )
      flash.now[:alert] = "Uploaded file type not supported"
      render :update, status: :unprocessable_entity
    end
  end

  def project_id
    params.permit(:project_id).require(:project_id)
  end

  private

  def authorize_user
    project = Project.find(project_id)

    if !current_user.able_to_edit?(project)
      flash[:alert] = t("projects.not_authorized")
      redirect_to project_path(project)
    end
  end

  def project
    Project.find(project_id)
  end

  def project_params
    params.require(:project).permit(
     files: []
    )
  end
end
