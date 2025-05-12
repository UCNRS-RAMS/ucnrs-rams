class Manager::ReserveInfo::AmenitiesAndRatesController < Manager::ApplicationController
  before_action :authenticate_user!
  before_action :confirm_current_reserve_manager!, unless: -> { super_admin? }

  layout "manager"

  def index
    @presenter = Manager::ReserveInfo::AmenitiesAndRatesIndexPresenter.new(
      reserve: current_reserve,
    )
  end
end
