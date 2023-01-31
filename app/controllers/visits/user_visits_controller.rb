class Visits::UserVisitsController < ApplicationController
  before_action :authenticate_user!

  def index
    @presenter = user_visit_index_presenter
  end

  def new
    @presenter = initialize_form_presenter(new_user_visit_params)
  end

  def edit
    form = UserVisitForm.new(params: { id: params[:id] })
    @presenter = Visits::UserVisitEditPresenter.new(
      form: form,
      display_institution_form: display_institution_form?,
    )
  end

  def create
    @presenter = initialize_form_presenter(user_visit_params)
    if @presenter.form.save
      create_log(action: :added, user_visit: @presenter.form.user_visit, visit: @presenter.form.visit)
      @presenter = initialize_form_presenter({ visit_id: params[:visit_id] })
      render template: "shared/visits/user_visits/_tables"
    elsif @presenter.add_visitor_partial == "guest" && @presenter.user_id.blank?
      redirect_to @presenter.new_user_visit_path({ add_visitor_partial: params[:add_visitor_partial], guest_name: @presenter.guest_name, show_add_guest_modal: true })
    elsif @presenter.add_visitor_partial == "team_members"
      @presenter.reset_visitor_partial
      render :new, status: :unprocessable_entity
    else
      render status: :unprocessable_entity
    end
  end

  def update
    form = UserVisitForm.new(params: user_visit_params)

    if form.save
      redirect_to visit_user_visits_path(user_visit.visit_id)
    else
      @presenter = Visits::UserVisitEditPresenter.new(
        form: form,
        display_institution_form: display_institution_form?,
      )
      render template: "visits/user_visits/edit", status: :unprocessable_entity
    end
  end

  def destroy
    @presenter = user_visit_index_presenter
    if user_visit.destroy
      render template: "shared/visits/user_visits/_tables"
    else
      render template: "shared/visits/user_visits/index", status: :unprocessable_entity
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

  def display_institution_form?
    params[:display_institution_form].present?
  end

  def new_user_visit_params
    {
      visit_id: params[:visit_id],
      user_id: params[:user_id],
      institution_id: params[:institution_id],
      guest_name: params[:guest_name],
    }
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
      institution: [
        :id,
        :name,
        :city,
        :country_id,
        :state_id,
        :institution_type,
      ],
    )
  end

  private

  def create_log(action:, user_visit:, visit:)
    LogForm.create(params: {
        action: action,
        user_id: current_user.id,
      },
      record: visit,
      record_about: user_visit
    )
  end
end
