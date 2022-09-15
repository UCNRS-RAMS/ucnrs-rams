class Manager::Visits::DetailController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_manager!

  def edit
    @form = VisitForm.new(user: current_user, params: { id: params[:visit_id] })
    @presenter = Manager::Visits::VisitsFormPresenter.new(user: current_user, form: @form)
  end

  def update
    @form = VisitForm.new(user: current_user, params: visit_params)
    if @form.save
      @presenter = Manager::Visits::VisitsFormPresenter.new(user: current_user, form: @form)
      flash.now[:notice] = "Updates were successfully made."
      render :edit
    else
      @presenter = Manager::Visits::VisitsFormPresenter.new(user: current_user, form: @form)
      render :edit, status: :unprocessable_entity
    end
  end

private

  def visit_params
    params.require(:visit).permit(
      :id,
      :purpose_of_visit,
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

  def visit
    Visit.find(visit_id)
  end

  def visit_id
    params.permit(:id).require(:id)
  end
end
