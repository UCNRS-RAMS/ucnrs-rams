class Manager::ReserveInfo::StaffAndNotificationsController < ApplicationController
  layout "manager"
  before_action :authenticate_user!

  def index
    @presenter = Manager::ReserveInfo::StaffAndNotificationsIndexPresenter.new(
      reserve: current_reserve,
    )
  end

  private

end
