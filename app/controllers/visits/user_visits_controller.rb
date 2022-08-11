class Visits::UserVisitsController < ApplicationController
  before_action :authenticate_user!

  def index
    @presenter = user_visit_index_presenter
  end

  def new
    @presenter = user_visit_index_presenter
  end

  def edit
    form = UserVisitForm.new(params: { id: params[:id] })
    @presenter = Visits::UserVisitEditPresenter.new(form: form)
  end

  def update
    form = UserVisitForm.new(params: user_visit_params)

    if form.save
      redirect_to visit_user_visits_path(user_visit.visit_id)
    else
      @presenter = Visits::UserVisitEditPresenter.new(form: form)
      render template: "visits/user_visits/edit", status: :unprocessable_entity
    end
  end

  def destroy
    visit_id = user_visit.visit_id
    if user_visit.destroy
      redirect_to visit_user_visits_path(visit_id)
    else
      @presenter = user_visit_index_presenter
      render template: "visits/user_visits/index", status: :unprocessable_entity
    end
  end

  private

  def user_visit_index_presenter
    Visits::UserVisitsIndexPresenter.new(
      current_step: 2,
      visit: visit,
      current_user: current_user,
      add_visitor_partial: params[:add_visitor_partial],
    )
  end

  def visit
    @visit ||= Visit.find_by(id: params[:visit_id])
  end

  def user_visit
    @user_visit ||= UserVisit.find(params[:id])
  end

  def user_visit_params
    params.require(:user_visit).permit(:id, :arrives_at, :departs_at)
  end
end
