class Manager::Visits::AnswersController < Manager::ApplicationController
  before_action :authenticate_user!
  before_action :confirm_reserve_manager!, only: [:destroy]
  before_action :confirm_manager!, only: [:show]

  def create
    form = Visits::VisitAnswersForm.new(
      visit: visit,
      params: answer_params,
    )

    if form.save
      redirect_to manager_reserve_visit_waivers_policies_path(reserve_id: current_reserve, visit_id: visit.id)
    else
      @presenter = Manager::Visits::QuestionsIndexPresenter.new(
        visit: visit,
      )
      flash.now[:alert] = I18n.t("visits.answers.missing_fileds_error")
      render :create, status: :unprocessable_entity
    end
  end

  private

  def visit
    Visit.find(params[:visit_id])
  end

  def answer_params
    return {} if params[:visit].blank?
    
    params.require(:visit).permit(
      permit_answers: {},
      reserve_answers: {},
    )
  end
end
