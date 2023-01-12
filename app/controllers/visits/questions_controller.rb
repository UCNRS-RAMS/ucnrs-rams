class Visits::QuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_having_user_visits, only: [:index]

  def index
    @presenter = Visits::QuestionsIndexPresenter.new(
      current_step: 3,
      visit: visit,
    )
  end

  private

  def confirm_having_user_visits
    if visit.user_visits.blank?
      redirect_to visit_user_visits_path(visit, format: :html), alert: I18n.translate(".visits.user_visits.no_visitor")
    end
  end

  def visit
    @visit ||= Visit.find(params[:visit_id])
  end
end
