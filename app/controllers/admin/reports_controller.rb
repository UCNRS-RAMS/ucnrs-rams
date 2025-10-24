class Admin::ReportsController < Manager::ApplicationController
  before_action :authenticate_user!
  before_action :confirm_admin!

  layout false

  def index
    @presenter = AnnualReport.where(
      reserve: 1..100,
      fiscal_year_ending: 2025,
    ).includes(:reserve)
  end
end
