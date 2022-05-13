class Manager::ReserveInfo::AmenitiesAndRatesController < ApplicationController
  layout "manager"
  before_action :authenticate_user!

  def index
    @presenter = Manager::ReserveInfo::AmenitiesAndRatesIndexPresenter.new(
      reserve: current_reserve,
    )
  end

  private

end
