class Visits::ReserveInputsController < ApplicationController
  before_action :authenticate_user!
  layout false

  def show
    @presenter = Visits::ReserveInputsPresenter.new(reserve)
    @form_values = Visit.new(special_needs: "", study_area: "")
  end

  private

  def reserve
    Reserve.find(params[:id])
  end
end
