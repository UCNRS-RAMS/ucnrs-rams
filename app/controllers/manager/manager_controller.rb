class Manager::ManagerController < ApplicationController

  def is_administrator_or_accountant!
    return true if current_reserve.personnel.role(current_user) == "Administrator" || current_reserve.personnel.role(current_user) == "Accountant"

    flash[:alert] = I18n.translate("manager.not_authorize")
    redirect_to root_url and return false
  end

  def is_administrator!
    return true if current_reserve.personnel.role(current_user) == "Administrator"

    flash[:alert] = I18n.translate("manager.not_authorize")
    redirect_to root_url and return false
  end
end
