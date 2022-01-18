class Projects::FundingsController < ApplicationController
  before_action :authenticate_user!

  def index
    @presenter = Projects::FundingsIndexPresenter.new(
      current_step: 4,
      project: project,
    )
    respond_to do |format|
      format.html
    end
  end

  def create
    form = ProjectFundingForm.new(
      project: project,
      params: project_fundings_params
    )
    if form.save
      redirect_to project_fundings_url(project)
    else
      @presenter = Projects::FundingsIndexPresenter.new(
        current_step: 4,
        project: project,
        form: form,
      )
      render :index, status: :unprocessable_entity
    end
  end

  def edit
    form = ProjectFundingForm.new(params: { id: funding.id })
    @presenter = Projects::FundingEditPresenter.new(form: form)
  end

  private

  def funding
    Funding.find(params[:id])
  end

  def project
    Project.find(params[:project_id])
  end

  def project_fundings_params
    params.require(:funding).permit(
      :id,
      :title,
      :is_funded,
      :is_submitted,
      :will_be_submitted,
      :was_denied,
      :principal_investigators,
      :co_principal_investigators,
      :start_date,
      :end_date,
      :sponsor,
      :sponsor_other,
      :award_amount,
      :grant_number,
      :funding_opportunity_number,
    )
  end
end
