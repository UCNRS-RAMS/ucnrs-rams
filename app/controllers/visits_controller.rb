class VisitsController < ApplicationController
  before_action :authenticate_user!

  def new
    @page = VisitsFormPresenter.new(user: current_user)
  end

  def create
    @form = VisitForm.new(user: current_user, params: visit_params)
    if @form.save
      redirect_to root_url
    else
      @page = VisitsFormPresenter.new(user: current_user, form: @form)
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
      amenities: [
        :amenity_id,
        :amenity_visit_id,
        :arrives_on,
        :departs_on,
        :amenity_rate_id,
        :number_of_people,
      ]
    )
  end
end
