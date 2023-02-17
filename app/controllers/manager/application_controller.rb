class Manager::ApplicationController < ApplicationController
  def confirm_current_reserve_manager!
    return true if current_user.manager_of_reserve?(current_reserve)

    flash[:notice] = I18n.translate("manager.not_a_manager_of_reserve")
    redirect_to root_url and return false
  end

  def is_administrator_or_accountant!
    return true if current_reserve.personnel.role(current_user) == "Administrator" ||
      current_reserve.personnel.role(current_user) == "Accountant"

    flash[:alert] = I18n.translate("manager.not_authorize")
    redirect_to root_url and return false
  end

  def is_administrator!
    return true if current_reserve.personnel.role(current_user) == "Administrator"

    flash[:alert] = I18n.translate("manager.not_authorize")
    redirect_to root_url and return false
  end
end
