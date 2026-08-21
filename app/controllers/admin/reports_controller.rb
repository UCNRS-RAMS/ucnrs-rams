class Admin::ReportsController < Manager::ApplicationController
  before_action :authenticate_user!
  before_action :confirm_admin!

  layout "admin"

  def index
    @presenter = Admin::ReportsIndexPresenter.new(
      fiscal_year_ending: params[:fiscal_year_ending],
    )
  end
end
