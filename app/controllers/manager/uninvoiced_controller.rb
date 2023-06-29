class Manager::UninvoicedController < Manager::ApplicationController
  before_action :authenticate_user!
  before_action :confirm_current_reserve_manager!, unless: -> { super_admin? }
  layout "manager"

  def index
    @presenter = Manager::UninvoicedIndexPresenter.new(
      reserve: current_reserve,
      page: page_number,
    )
  end

  private

  def page_number
    params[:page]
  end
end
