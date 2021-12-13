class VisitsController < ApplicationController
  before_action :authenticate_user!

  def new
    @presenter = VisitsFormPresenter.new(user: current_user)
  end

  def create
    @form = VisitForm.new(user: current_user, params: visit_params)
    if @form.save
      redirect_to root_url
    else
      @presenter = VisitsFormPresenter.new(user: current_user, form: @form)
      render :new, status: :unprocessable_entity
    end
  end

  private

  def visit_params
    params.require(:visit).permit(
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
        :arrives_on,
        :arrives_at,
        :departs_on,
        :departs_at,
        :amenity_rate_id,
        :number_of_people,
      ]
    )
  end

  def project_type
    params[:project_type]
  end
end
