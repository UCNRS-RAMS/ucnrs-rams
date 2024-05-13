class VisitsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_edit_access, only: [:edit]

  def new
    @form = VisitForm.new(user: current_user, params: visit_new_params)
    @presenter = VisitsFormPresenter.new(user: current_user, form: @form)
  end

  def create
    @form = VisitForm.new(user: current_user, params: visit_params)
    if @form.save
      create_log2(action: :created, visit: @form.visit, user: current_user)
      redirect_to visit_user_visits_path(@form.visit, format: :html)
    else
      @presenter = VisitsFormPresenter.new(user: current_user, form: @form)
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
      create_log2(action: :updated, visit: @form.visit, user: current_user)
      redirect_to visit_user_visits_path(@form.visit, format: :html)
    else
      @form.editing = true
      @presenter = VisitsFormPresenter.new(user: current_user, form: @form)
      render :edit, status: :unprocessable_entity
    end
  end

  def show
    @presenter = VisitShowPresenter.new(visit)
  end

  def amenity_booking
    form = Visits::AmenityForm.new(params: amenity_booking_params)
    @presenter = Visits::AmenityPresenter.new(amenity, user: current_user, form: [form])
  end

  def cancel
    form = VisitForm.new(user: current_user, params: {id: visit_id})
    if form.cancel_visit
      create_log2(action: :cancelled, visit: form.visit, user: current_user)
      redirect_to visit_path, notice: I18n.translate("visits.show.successfully_cancelled")
    else
      flash.now[:alert] = I18n.translate("visits.show.could_not_cancel")
      render :show
    end
  end

  private

  def check_edit_access
    return if visit.status == "incomplete"

    unless visit.starts_at.to_date > Date.today && visit.status == "in_review"
      flash[:alert] = I18n.translate("manager.not_editable")
      redirect_to visit_path(id: visit.id)
    end
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

  def visit_new_params
    params.fetch(:visit, {})
  end

  def visit
    Visit.find(visit_id)
  end

  def visit_id
    params.permit(:id).require(:id)
  end

  def amenity_booking_params
    params.permit(:amenity_id, :amenity_rate_id)
  end

  def create_log(action:, visit:, project:)
    LogForm.create(params: {
        action: action,
        user_id: current_user.id,
      },
      record: visit,
      record_about: project
    )
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
