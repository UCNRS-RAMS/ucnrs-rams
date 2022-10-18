class Manager::Visits::ReserveInfoController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_reserve_manager!
  before_action :presenter

  def index
  end

  def create
    @form = Visits::VisitAnswersForm.new(
      visit: visit,
      params: answer_params,
    )

    if @form.save
      flash.now[:notice] = I18n.translate("manager.update_message")
    else
      flash.now[:alert] = I18n.translate("manager.error_message")
    end
    render :index
  end

  private

  def visit
    @visit ||= Visit.find(params[:visit_id])
  end

  def presenter
    @presenter = Manager::Visits::QuestionsIndexPresenter.new(
      visit: visit,
    )
  end

  def answer_params
    params.require(:visit).permit(
      permit_answers: {},
      reserve_answers: {},
    )
  end
end
