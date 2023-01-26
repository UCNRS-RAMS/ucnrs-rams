class Manager::Visits::ReserveInfoController < Manager::ManagerController
  before_action :authenticate_user!
  before_action :confirm_reserve_manager!
  before_action :is_administrator_or_accountant!, only: [:create]

  def index
    @presenter = Manager::Visits::QuestionsIndexPresenter.new(
      visit: visit,
    )
  end

  def create
    @presenter = Manager::Visits::QuestionsIndexPresenter.new(
      visit: visit,
    )
    form = Visits::VisitAnswersForm.new(
      visit: visit,
      params: answer_params,
    )

    if form.save
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

  def answer_params
    params.require(:visit).permit(
      permit_answers: {},
      reserve_answers: {},
    )
  end
end
