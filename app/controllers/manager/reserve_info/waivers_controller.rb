class Manager::ReserveInfo::WaiversController < ApplicationController
  layout "manager"
  before_action :authenticate_user!

  def index
    @presenter = Manager::ReserveInfo::WaiversIndexPresenter.new(
      reserve: current_reserve,
    )
  end

  private

end
