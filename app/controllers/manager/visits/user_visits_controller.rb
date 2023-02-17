class Manager::Visits::UserVisitsController < Manager::ApplicationController
  before_action :authenticate_user!
  before_action :confirm_current_reserve_manager!, unless: -> { super_admin? }
  before_action :is_administrator_or_accountant!, only: [:update, :destroy]

  def index
    @presenter = user_visit_index_presenter
  end

  def edit
    form = UserVisitForm.new(params: { id: params[:id] })
    @presenter = Manager::Visits::UserVisitEditPresenter.new(
      form: form,
      display_institution_form: display_institution_form?,
    )
  end

  def update
    form = UserVisitForm.new(params: user_visit_params)
    if form.save
      redirect_to manager_reserve_visit_user_visits_path(params[:reserve_id], user_visit.visit_id)
    else
      @presenter = Manager::Visits::UserVisitEditPresenter.new(
        form: form,
        display_institution_form: display_institution_form?,
      )
      render template: "manager/visits/user_visits/edit", status: :unprocessable_entity
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
    Manager::Visits::UserVisitsIndexPresenter.new(
      current_user: current_user,
      visit: visit,
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

  def user_visit_params
    params.require(:user_visit).permit(
      :id,
      :arrives_at,
      :departs_at,
      :count,
      :role,
      :actual_days,
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
end
