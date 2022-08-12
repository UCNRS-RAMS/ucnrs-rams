class Visits::UserVisitsController < ApplicationController
  before_action :authenticate_user!

  def index
    @presenter = user_visit_index_presenter
  end

  def new
    @presenter = initialize_form_presenter({ visit_id: params[:visit_id], guest_name: params[:guest_name] })
  end

  def edit
    form = UserVisitForm.new(params: { id: params[:id] })
    @presenter = Visits::UserVisitEditPresenter.new(form: form)
  end

  def create
    @presenter = initialize_form_presenter(user_visit_params)
    if @presenter.form.save
      @presenter = initialize_form_presenter({ visit_id: params[:visit_id] })
      render template: "visits/user_visits/_tables", status: :ok
    elsif @presenter.add_visitor_partial == "guest" && @presenter.user_id.blank?
      redirect_to @presenter.new_user_visit_path({ add_visitor_partial: params[:add_visitor_partial], guest_name: @presenter.guest_name, show_add_guest_modal: true })
    else
      render status: :unprocessable_entity
    end
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
    @presenter = user_visit_index_presenter
    if user_visit.destroy
      render template: "visits/user_visits/_tables", status: :ok
    else
      render template: "visits/user_visits/index", status: :unprocessable_entity
    end
  end

  private

  def user_visit_index_presenter
    Visits::UserVisitsIndexPresenter.new(
      current_step: 2,
      current_user: current_user,
      visit: visit,
    )
  end

  def initialize_form_presenter(form_params)
    form = UserVisitForm.new(params: form_params)
    Visits::UserVisitFormPresenter.new(
      current_user: current_user,
      add_visitor_partial: params[:add_visitor_partial],
      form: form,
      show_add_guest_modal: params[:show_add_guest_modal].present?,
    )
  end

  def visit
    @visit ||= Visit.find_by(id: params[:visit_id])
  end

  def user_visit
    @user_visit ||= UserVisit.find(params[:id])
  end

  def user_visit_params
    params.require(:user_visit).permit(
      :id,
      :arrives_at,
      :departs_at,
      :count,
      :role,
      :institution_id,
      :user_id,
      :visit_id,
      :guest_name,
    )
  end
end
