class Manager::ReserveInfo::PermitsController < ApplicationController
  layout "manager"
  before_action :authenticate_user!

  def index
    @presenter = Manager::ReserveInfo::PermitsIndexPresenter.new(
      reserve: current_reserve,
    )
  end

  private

end
