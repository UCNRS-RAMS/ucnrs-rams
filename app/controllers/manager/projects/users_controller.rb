class Manager::Projects::UsersController < Manager::ManagerController
  before_action :is_administrator!, only: [:create]
  layout false

  def new
    form = UserForm.new
    @presenter = Manager::Projects::UserNewPresenter.new(
      form: form,
      project: project,
      reserve: current_reserve,
    )
  end

  def create
    form = UserForm.new(
      applicant: current_user,
      project: project,
      params: user_params,
    )

    respond_to do |format|
      if form.save
        format.turbo_stream { redirect_to manager_reserve_project_team_memberships_path(current_reserve, project) }
        format.html { redirect_to manager_reserve_project_team_memberships_path(current_reserve, project) }
      else
        @presenter = Manager::Projects::UserNewPresenter.new(
          form: form,
          project: project,
          reserve: current_reserve,
        )

        format.turbo_stream do
          render template: "manager/projects/users/new",
            status: :unprocessable_entity
        end
        format.html do
          render template: "manager/projects/users/new",
            status: :unprocessable_entity
        end
      end
    end
  end

  private

  def project
    @project ||= Project.find(params[:project_id])
  end

  def user_params
    params.require(:user).permit(
      :id,
      :project_id,
      :institution_id,
      :institution_name,
      :first_name,
      :last_name,
      :email,
      :user_role,
      :project_role,
      :reserve_id,
    )
  end
end
