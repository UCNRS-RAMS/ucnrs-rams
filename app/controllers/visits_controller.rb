class VisitsController < ApplicationController
  before_action :authenticate_user!

  def new
    @page = VisitsNewPresenter.new
  end

  def create
    @form = VisitForm.new(visit_params)
    @page = VisitsNewPresenter.new(form: @form)
    render :new
  end

  private

  def visit_params
    params.require(:visit).permit(
      :project_id,
      :public_use_category,
      :purpose_of_visit,
      :reserve_id,
      :start_date,
      :start_time,
      :end_date,
      :end_time,
      :special_needs,
      amenities: [
        :id,
        :dates,
        :rate,
        :people,
      ]
    )
  end
end
