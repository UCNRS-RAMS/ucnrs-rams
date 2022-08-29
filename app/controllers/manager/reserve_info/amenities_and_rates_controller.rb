class Manager::ReserveInfo::AmenitiesAndRatesController < ApplicationController
  layout "manager"
  before_action :authenticate_user!
  before_action :confirm_manager!

  def index
    @presenter = Manager::ReserveInfo::AmenitiesAndRatesIndexPresenter.new(
      reserve: current_reserve,
    )
  end

  private

end
