class Manager::VisitsController < Manager::ApplicationController
  before_action :authenticate_user!
  before_action :confirm_current_reserve_manager!, unless: -> { super_admin? }, only: [:destroy]
  before_action :confirm_manager!, only: [:show]
  before_action :is_administrator_or_accountant!, only: [:destroy]

  layout "manager"

  def new
    @presenter = VisitsFormPresenter.new(user: user)
  end

  def create
    @form = VisitForm.new(user: user, params: visit_params)
    if @form.save
      redirect_to manager_reserve_visit_user_visits_path(reserve_id: reserve_id, visit_id: @form.visit, format: :html)
    else
      @presenter = VisitsFormPresenter.new(user: user, form: @form)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @form = VisitForm.new(user: current_user, params: { id: visit.id }, editing: true)
    @presenter = VisitsFormPresenter.new(user: current_user, form: @form)
  end

  def update
    @form = VisitForm.new(user: current_user, params: visit_params)
    if @form.save
      redirect_to manager_reserve_visit_user_visits_path(reserve_id: reserve_id, visit_id: @form.visit, format: :html)
    else
      @form.editing = true
      @presenter = VisitsFormPresenter.new(user: current_user, form: @form)
      render :edit, status: :unprocessable_entity
    end
  end

  def show
    @presenter = Manager::VisitShowPresenter.new(visit: visit, current_user: current_user, selected_tab: params[:selected_tab])
  end

  def destroy
    if visit.destroy
      flash[:notice] = I18n.t("manager.visits.successfully_deleted_visit")
      redirect_to manager_reserve_dashboard_path(format: :html)
    else
      flash[:alert] = I18n.t("manager.visits.cannot_delete_visit")
      redirect_to manager_reserve_visit_path
    end
  end

  private

  def visit
    Visit.find(params[:id])
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
end
