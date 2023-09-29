class  Manager::Visits::QuestionsController < Manager::ApplicationController
  before_action :authenticate_user!
  before_action :confirm_reserve_manager!, unless: -> { super_admin? }
  before_action :confirm_having_user_visits, only: [:index]

  layout "manager"

  def index
    @presenter = Manager::Visits::QuestionsIndexPresenter.new(
      visit: visit,
      save_partial: "manager/visits/questions/save_btn",
      form_url: manager_reserve_visit_answers_path(reserve_id: current_reserve, visit_id: visit.id)
    )
  end

  private

  def confirm_having_user_visits
    if visit.user_visits.blank?
      redirect_to manager_reserve_visit_user_visits_path(current_reserve, visit, format: :html), alert: I18n.translate(".visits.user_visits.no_visitor")
    end
  end

  def visit
    @visit ||= Visit.find(params[:visit_id])
  end
end
