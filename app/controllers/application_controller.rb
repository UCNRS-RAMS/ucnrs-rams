class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  helper_method :current_reserve

  def current_reserve
    @current_reserve ||= Reserve.find_by(id: params[:reserve_id])
  end

  def confirm_reserve_manager!
    return true if current_user.manager_of_reserve?(current_reserve)

    flash[:notice] = I18n.translate("manager.not_a_manager_of_reserve")
    redirect_to root_url and return false
  end

  def confirm_manager!
    return true if current_user.is_manager?

    flash[:notice] = I18n.translate("manager.not_a_manager")
    redirect_to root_url and return false
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
end
