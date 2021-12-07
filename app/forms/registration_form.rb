class RegistrationForm
  attr_reader :user

  def initialize(params = {})
    @params = params
    @user = User.new(
      gender_identity: @params[:gender_identity],
      first_name: @params[:first_name],
      last_name: @params[:last_name],
      address_line_1: @params[:address_line_1],
      address_line_2: @params[:address_line_2],
      address_city: @params[:address_city],
      address_postal_code: @params[:address_postal_code],
      address_state_id: @params[:address_state_id],
      address_country_id: @params[:address_country_id],
      email: @params[:email],
      phone_number: @params[:phone_number],
      secondary_phone_number: @params[:secondary_phone_number],
      emergency_contact_full_name: @params[:emergency_contact_full_name],
      emergency_contact_phone_number: @params[:emergency_contact_phone_number],
      institution_id: institution_id,
      role: @params[:role],
      billing_person_full_name: @params[:billing_person_full_name],
      billing_person_phone_number: @params[:billing_person_phone_number],
      billing_person_email: @params[:billing_person_email],
      billing_address_same_as_current: @params[:billing_address_same_as_current],
      billing_address_line_1: @params[:billing_address_line_1],
      billing_address_line_2: @params[:billing_address_line_2],
      billing_address_city: @params[:billing_address_city],
      billing_address_postal_code: @params[:billing_address_postal_code],
      billing_address_state_id: @params[:billing_address_state_id],
      billing_address_country_id: @params[:billing_address_country_id],
      advisor: @params[:advisor],
      password: @params[:password],
      password_confirmation: @params[:password_confirmation],
      accessibility_requirements: @params[:accessibility_requirements],
      backup_email_address: @params[:backup_email_address],
      terms_accepted: @params[:terms_accepted],
      age_range: @params[:age_range]
    )

    if billing_address_same_as_current_address?
      copy_address_fields_to_billing_address
    end

    if terms_accepted?
      user.assign_attributes(terms_accepted_at: terms_accepted_at)
    end
  end

  delegate :errors, to: :user

  def submit
    return unless user.valid?
    user.save
  end

  private

  attr_reader :params

  def terms_accepted?
    ActiveModel::Type::Boolean.new.cast(params[:terms_accepted])
  end

  def terms_accepted_at
    Time.current
  end

  def copy_address_fields_to_billing_address
    user.assign_attributes(
      billing_address_line_1: params[:address_line_1],
      billing_address_line_2: params[:address_line_2],
      billing_address_city: params[:address_city],
      billing_address_postal_code: params[:address_postal_code],
      billing_address_state_id: params[:address_state_id],
      billing_address_country_id: params[:address_country_id],
    )
  end

  def billing_address_same_as_current_address?
    ActiveModel::Type::Boolean.new.cast(params[:billing_address_same_as_current])
  end

  def institution_id
    Institution.find_by(name: params[:institution])&.id
  end
end
