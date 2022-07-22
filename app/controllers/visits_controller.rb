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

  def show
    @presenter = VisitShowPresenter.new(visit)
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
        :amenity_rate_id,
        amenity_visits: [
          :arrives_on,
          :arrives_at,
          :departs_on,
          :departs_at,
          :number_of_people,
        ],
      ],
    )
  end

  def visit
    Visit.find(visit_id)
  end

  def visit_id
    params.permit(:id).require(:id)
  end
end
