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
      redirect_to visit_questions_path(visit), alert: "Required fields are missing"
    end
  end

  private

  def visit
    Visit.find(params[:visit_id])
  end

  def answer_params
    params.require(:visit).permit(
      permit_answers: {},
      reserve_answers: {},
    )
  end
end
