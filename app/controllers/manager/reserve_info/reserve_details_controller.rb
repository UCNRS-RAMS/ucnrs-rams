class Manager::ReserveInfo::ReserveDetailsController < ApplicationController
  layout "manager"
  before_action :authenticate_user!

  def index
    @presenter = Manager::ReserveInfo::ReserveDetailsIndexPresenter.new(
      reserve: current_reserve,
    )
  end

  private

end
