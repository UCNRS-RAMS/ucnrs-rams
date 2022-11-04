class Manager::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_reserve_manager!
  layout "manager"

  def index
    @presenter = Manager::UsersIndexPresenter.new(
      page: page_number,
      filter: filter,
    )
  end

  private
 
  def page_number
    params[:page]
  end

  def filter
    if params[:filter].present?
      params.require(:filter).permit(
        :user_search,
        :sort_by,
        :user_role,
        :user_institution_type,
      )
    end
  end
end
