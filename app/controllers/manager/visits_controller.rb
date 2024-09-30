class Manager::VisitsController < Manager::ApplicationController
  before_action :authenticate_user!
  before_action :confirm_current_reserve_manager!, only: [:destroy], unless: -> { super_admin? }
  before_action :confirm_manager!, only: [:show], unless: -> { super_admin? }
  before_action :is_administrator_or_accountant!, only: [:destroy], unless: -> { super_admin? }

  layout "manager"

  def new
    form = VisitForm.new(user: user, params: {reserve_id: current_reserve.id})
    @presenter = Manager::VisitsFormPresenter.new(
      user: user,
      form: form,
      project_url: new_manager_reserve_project_path(reserve_id: current_reserve, user_id: user.id)
    )
  end

  def create
    @form = VisitForm.new(user: user, params: visit_params)
    if @form.save
      create_log2(action: :created, visit: @form.visit, user: current_user)
      redirect_to manager_reserve_visit_user_visits_path(reserve_id: reserve_id, visit_id: @form.visit, format: :html)
    else
      @presenter = Manager::VisitsFormPresenter.new(user: user, form: @form)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @form = VisitForm.new(user: current_user, params: { id: visit.id }, editing: true)
    @presenter = Manager::VisitsFormPresenter.new(user: current_user, form: @form)
  end

  def update
    @form = VisitForm.new(user: current_user, params: visit_params)
    if @form.save
      create_log2(action: :updated, visit: @form.visit, user: current_user)
      redirect_to manager_reserve_visit_user_visits_path(reserve_id: reserve_id, visit_id: @form.visit, format: :html)
    else
      @form.editing = true
      @presenter = Manager::VisitsFormPresenter.new(user: current_user, form: @form)
      render :edit, status: :unprocessable_entity
    end
  end

  def show
    @presenter = Manager::VisitShowPresenter.new(visit: visit, current_user: current_user, selected_tab: params[:selected_tab])
  end

  def destroy
    if visit.destroy
      create_log2(action: :deleted, visit: visit, user: current_user)
      flash[:notice] = I18n.t("manager.visits.successfully_deleted_visit")
      redirect_to manager_reserve_dashboard_path(format: :html)
    else
      flash[:alert] = I18n.t("manager.visits.cannot_delete_visit")
      redirect_to manager_reserve_visit_path
    end
  end

  private

  def visit
    @visit ||= Visit.find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    flash[:alert] = I18n.t("manager.visits.cannot_find_visit")
    redirect_to manager_reserve_dashboard_path
  end

  def user
    User.find_by(id: params[:user_id])
  end

  def amenity
    @amenity ||= Amenity.find_by(id: params[:amenity_id])
  end

  def visit_params
    params.require(:visit).permit(
      :id,
      :project_id,
      :project_type,
      :public_use_category,
      :purpose_of_visit,
      :reserve_id,
      :start_date,
      :start_time,
      :end_date,
      :end_time,
      :special_needs,
      :study_area,
      amenities: [
        :amenity_id,
        :amenity_visit_id,
        :amenity_rate_id,
        { amenity_visits: {} },
      ],
    )
  end

  def reserve_id
    params.permit(:reserve_id).require(:reserve_id)
  end

  def visit_id
    params.permit(:id).require(:id)
  end

  def amenity_booking_params
    params.permit(:amenity_id, :amenity_rate_id)
  end

  def create_log2(action:, visit:, user:)
    LogForm2.create(
      params: {
        action: action,
        record: visit.project,
        record_about: visit,
        user: user,
      }
    )
  end
end
