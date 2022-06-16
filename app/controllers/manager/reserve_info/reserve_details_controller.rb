class Manager::ReserveInfo::ReserveDetailsController < ApplicationController
  layout "manager"
  before_action :authenticate_user!
  before_action :confirm_manager!

  def edit
    form = ReserveForm.new(reserve: current_reserve)
    @presenter = Manager::ReserveInfo::ReserveFormPresenter.new(form)
  end

  def update
    form = ReserveForm.new(reserve: current_reserve, params: reserve_params)
    if form.save
      flash[:notice] = "Update success."
      redirect_to edit_manager_reserve_reserve_info_reserve_details_path(form.reserve, format: :html)
    else
      @presenter = Manager::ReserveInfo::ReserveFormPresenter.new(form)
      render template: "manager/reserve_info/reserve_details/edit", status: :unprocessable_entity
    end
  end

  private

  def reserve_params
    params.require(:reserve).permit(
      :short_name,
      :pulldown_name,
      :directions,
      :rules,
      :rates,
      :managing_campus_id,
      :department,
      :address_line_1,
      :address_line_2,
      :address_city,
      :address_postal_code,
      :billing_address_line_1,
      :billing_address_line_2,
      :billing_city,
      :billing_address_postal_code,
      :applicaton_email_address,
      :email_address,
      :phone_number,
      :fax_number,
      :check_payable_to_name,
      :home_page_url,
      :logo_url,
      :directions_url,
      :rules_url,
      :rates_url,
      :research_projects_accepted,
      :class_projects_accepted,
      :public_projects_accepted,
      :housing_projects_accepted,
      :conference_projects_accepted,
      :public_calendar_access,
      :how_to_contact,
      :approval_message,
      :email_message_2,
      :email_message_3,
      :email_message_4,
      :latitude,
      :longitude,
      :special_needs_statement,
      :invoice_message,
      :tax_id_number,
      :invoice_message_footer,
      :year_reserve_established,
      :show_rate_table,
      :ldap_address,
      :outside_reservation_system_url,
      :outside_reservation_system_text,
      :doi,
      :google_calendar_id,
      :reserve_alert_message_enabled,
      :reserve_alert_message,
      :code_of_conduct_url,
      :zotero_url,
      :zotero_login,
      :zotero_password,
      :facility_group_name,
      :internet_status,
      :drop_box_login,
      :drop_box_password,
      :drop_box_request_url,
      :amenity_group_label_1,
      :amenity_group_label_2,
      :amenity_group_label_3,
      :amenity_group_label_4,
      :amenity_group_label_5,
      :created_at,
      :updated_at,
      :bill_name,
      :administrative_group_name,
      :administrative_group_name_acronym,
      :administrative_group_state,
      :address_state_id,
      :address_country_id,
      :billing_address_state_id,
      :billing_address_country_id,
      :latitude_degrees,
      :latitude_minutes,
      :latitude_seconds,
      :latitude_hemisphere,
      :longitude_degrees,
      :longitude_minutes,
      :longitude_seconds,
      :longitude_hemisphere,
      :description,
    )
  end
end
