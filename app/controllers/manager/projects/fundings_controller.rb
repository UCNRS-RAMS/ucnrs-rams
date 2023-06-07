class Manager::Projects::FundingsController < Manager::ApplicationController
  before_action :authenticate_user!
  before_action :confirm_current_reserve_manager!, unless: -> { super_admin? }
  before_action :is_administrator!, only: [:create, :update, :destroy]

  def index
    @presenter = Manager::Projects::FundingsIndexPresenter.new(
      project: project,
      reserve: current_reserve,
    )
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def edit
    form = ProjectFundingForm.new(params: { id: funding.id })
    @presenter = Manager::Projects::FundingEditPresenter.new(form: form, reserve: current_reserve)
  end

  def create
    form = ProjectFundingForm.new(
      project: project,
      params: project_fundings_params,
    )
    if form.save
      redirect_to manager_reserve_project_fundings_path(current_reserve, project.id)
    else
      @presenter = Manager::Projects::FundingsIndexPresenter.new(
        project: project,
        form: form,
        reserve: current_reserve,
      )
      render :index, status: :unprocessable_entity
    end
  end

  def update
    form = ProjectFundingForm.new(params: project_fundings_params)
    respond_to do |format|
      if form.save
        format.html { redirect_to manager_reserve_project_fundings_path(current_reserve, form.project_id) }
        format.turbo_stream { redirect_to manager_reserve_project_fundings_path(current_reserve, form.project_id) }
      else
        @presenter = Manager::Projects::FundingEditPresenter.new(form: form, reserve: current_reserve)
        format.html do
          render template: "manager/projects/fundings/edit",
            status: :unprocessable_entity
        end
        format.turbo_stream do
          render template: "manager/projects/fundings/edit",
            status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    funding.destroy
    redirect_to manager_reserve_project_fundings_path(current_reserve, project.id)
  end

  private

  def project
    @project ||= Project.find(project_id)
  end

  def project_id
    params.permit(:project_id).require(:project_id)
  end

  def funding
    @funding ||= Funding.find(params[:id])
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
