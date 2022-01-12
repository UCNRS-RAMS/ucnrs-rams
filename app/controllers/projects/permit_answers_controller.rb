class Projects::PermitAnswersController < ApplicationController
  before_action :authenticate_user!

  def create
    form = ProjectPermitAnswersForm.new(
      project: project,
      params: permit_answers_params,
    )

    if form.save
      redirect_to root_path
    else
      # Do some error stuff, eventually.
    end
  end

  private

  def project
    Project.find(params[:project_id])
  end

  def permit_answers_params
    params.require(:answers)
  end
end
