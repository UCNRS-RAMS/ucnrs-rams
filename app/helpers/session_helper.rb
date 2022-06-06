module SessionHelper
  def current_reserve
    @current_reserve ||= Reserve.select(:id, :name, :managing_campus_id).eager_load(:managing_campus).find_by(id: params[:reserve_id])
  end

  def confirm_manager!
    return true if current_user.manager_of_reserve?(current_reserve)

    flash[:notice] = "You are not a manager of the reserve."
    redirect_to root_url and return false
  end
end
