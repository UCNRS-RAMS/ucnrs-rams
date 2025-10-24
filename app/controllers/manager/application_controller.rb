class Manager::ApplicationController < ApplicationController
  def confirm_current_reserve_manager!
    return true if current_user.manager_of_reserve?(current_reserve)

    respond_to_modal_turbo_frame(flash_msg: I18n.translate("manager.not_a_manager_of_reserve"))
  end

  def is_administrator_or_accountant!
    return true if current_reserve.personnel.role(current_user).in? ["Administrator", "Accountant"]

    respond_to_modal_turbo_frame(flash_msg: I18n.translate("manager.not_authorize"))
  end

  def is_administrator!
    return true if current_reserve.personnel.role(current_user).in? ["Administrator"]

    respond_to_modal_turbo_frame(flash_msg: I18n.translate("manager.not_reserve_administrator"))
  end

  def confirm_reserve_manager!
    return true if user.manager_of_reserve?(current_reserve)

    respond_to_modal_turbo_frame(flash_msg: I18n.translate("manager.not_a_manager_of_reserve"))
  end

  private

  def user
    params[:user_id].present? ? User.find_by(id: params[:user_id]) : current_user
  end
end
