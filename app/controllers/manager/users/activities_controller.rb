class Manager::Users::ActivitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_reserve_manager!
  layout "manager"

  def index
    @presenter = Manager::Users::ActivitiesIndexPresenter.new(
      user: user,
      visits_page: visits_page_number,
      projects_page: projects_page_number,
      invoices_page: invoices_page_number,
    )
  end

  private

  def user
    @user ||= User.find(params[:user_id])
  end

  def visits_page_number
    params[:visits_page]
  end

  def projects_page_number
    params[:projects_page]
  end

  def invoices_page_number
    params[:invoices_page]
  end
end
