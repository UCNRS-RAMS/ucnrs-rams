class Visits::AnswersController < ApplicationController
  before_action :authenticate_user!

  def create
    form = Visits::VisitAnswersForm.new(
      visit: visit,
      params: answer_params,
    )

    if form.save
      redirect_to visit_waivers_policies_path
    else
      @presenter = Visits::QuestionsIndexPresenter.new(
        current_step: 3,
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
