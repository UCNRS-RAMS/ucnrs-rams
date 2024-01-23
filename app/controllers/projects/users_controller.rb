class Projects::UsersController < ApplicationController
  layout false

  def new
    form = UserForm.new
    @presenter = Projects::UserNewPresenter.new(
      form: form,
      project: project,
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
        format.turbo_stream { redirect_to project_team_memberships_path(project) }
        format.html { redirect_to project_team_memberships_path(project) }
      else
        @presenter = Projects::UserNewPresenter.new(
          form: form,
          project: project,
        )

        format.turbo_stream do
          render template: "projects/users/new",
            status: :unprocessable_entity
        end
        format.html { render status: :unprocessable_entity }
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
      :phone_number,
      :emergency_contact_full_name,
      :emergency_contact_phone_number,
      :address_country_id,
      :address_line_1,
      :address_city,
      :address_state_id,
      :address_postal_code,
    )
  end
end
