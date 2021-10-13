class Visits::ReserveInputsController < ApplicationController
  before_action :authenticate_user!
  layout false

  def show
    @page = Visits::ReserveInputsPresenter.new(reserve)
    @form_values = OpenStruct.new(special_needs: "")
  end

  private

  def reserve
    Reserve.find(params[:id])
  end
end
