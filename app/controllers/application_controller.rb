class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :turbo_frame_request_variant
  before_action :set_layout_presenter, if: -> { request.format.html? }

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

  def confirm_admin!
    return true if super_admin?

    respond_to_modal_turbo_frame(
      flash_msg: "You are not an admin",
    )
  end

  def super_admin?
    current_user.admin?
  end

  private

  def set_layout_presenter
    @layout_presenter ||= LayoutPresenter.new(
      current_user: current_user,
      current_reserve: current_reserve,
      controller_path: controller_path,
      dashboard: session[:dashboard],
    )
  end

  def turbo_frame_request_variant
    request.variant = :turbo_frame if turbo_frame_request?
  end

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

  def validate_user_as_visit_project_member!
    valid_visit_project_member = current_user
      .project_team_memberships
      .is_active
      .joins(project: :visits)
      .where(project: { visits: { id: params[:id] } })
      .first

    if !valid_visit_project_member
      flash[:alert] = "You are not authorized."
      redirect_to home_index_path
    end
  end

  def validate_user_as_project_member!
    valid_project_member = current_user
      .project_team_memberships
      .is_active
      .joins(:project)
      .where(project: { id: params[:id] } )
      .first

    if !valid_project_member
      flash[:alert] = "You are not authorized."
      redirect_to home_index_path
    end
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
      dashboard_index_path
    end
  end
end
