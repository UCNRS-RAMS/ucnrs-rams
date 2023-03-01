class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :turbo_frame_request_variant

  helper_method :current_reserve
  helper_method :super_admin?

  def current_reserve
    @current_reserve ||= Reserve.find_by(id: params[:reserve_id])
  end

  def confirm_manager!
    return true if current_user.is_manager?

    flash[:notice] = I18n.translate("manager.not_a_manager")
    redirect_to root_url and return false
  end

  def super_admin?
    current_user.admin?
  end

  private

  def turbo_frame_request_variant
    request.variant = :turbo_frame if turbo_frame_request?
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:registrations, keys: [
      :first_name,
      :last_name,
      :gender_identity,
      :age_range,
      :phone_number,
      :secondary_phone_number,
      :accessibility_requirements,
      :backup_email_address,
      :role,
      :institution,
      :orcid,
      :advisor,
      :emergency_contact_full_name,
      :emergency_contact_phone_number,
      :address_country_id,
      :address_line_1,
      :address_line_2,
      :address_city,
      :address_state_id,
      :address_postal_code,
      :billing_address_same_as_current,
      :billing_address_country_id,
      :billing_address_line_1,
      :billing_address_line_2,
      :billing_address_city,
      :billing_address_state_id,
      :billing_address_postal_code,
      :billing_person_full_name,
      :billing_person_email,
      :billing_person_phone_number,
      :terms_accepted_at,
    ])
  end

  def after_sign_in_path_for(current_user)
    if current_user.is_manager?
      manager_reserve_dashboard_path(current_user.managed_reserves.first)
    else
      root_path
    end
  end
end
