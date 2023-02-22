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

  private

  def respond_to_modal_turbo_frame(flash_msg: nil)
    respond_to do |format|
      format.html do |variant|
        variant.turbo_frame {
          flash.now[:alert] = flash_msg
          render partial: "modals/flash", status: :unprocessable_entity and return
        }
        variant.none {
          flash[:alert] = flash_msg
          redirect_back fallback_location: root_url and return
        }
      end
    end
  end
end
