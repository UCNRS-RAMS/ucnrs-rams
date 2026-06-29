class Manager::UsersController < Manager::ApplicationController
  before_action :authenticate_user!
  before_action :confirm_current_reserve_manager!, unless: -> { super_admin? }

  layout "manager"

  def index
    @presenter = Manager::UsersIndexPresenter.new(
      page: page_number,
      filter: filter,
    )
  end

  def edit
    form = RegistrationForm.new(user: user)
    @presenter = Manager::UserEditPresenter.new(form)
  end

  def update
    form = RegistrationForm.new(user: user, params: user_params, validate_orcid: true)
    @presenter = Manager::UserEditPresenter.new(form)

    if form.submit
      flash.now[:notice] = I18n.t(".devise.registrations.flash.updated")
      render :edit
    else
      flash.now[:error] = I18n.t(".devise.registrations.flash.error")
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user
    @user ||= User.find(params[:id])
  end


  def user_params
    user_attributes = params.require(:user)
    permitted_attributes = user_attributes.permit(
      :first_name,
      :last_name,
      :email,
      :password,
      :password_confirmation,
      :gender_identity,
      :age_range,
      :phone_number,
      :secondary_phone_number,
      :accessibility_requirements,
      :backup_email_address,
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
    )

    permitted_attributes.merge(sanitized_user_attributes(user_attributes))
  end

  def sanitized_user_attributes(user_attributes)
    {}.tap do |attributes|
      role = user_attributes[:role]
      attributes[:role] = role if valid_user_role?(role)

      orcid_authenticated = user_attributes[:orcid_authenticated]
      if [true, false].include?(ActiveModel::Type::Boolean.new.cast(orcid_authenticated))
        attributes[:orcid_authenticated] = ActiveModel::Type::Boolean.new.cast(orcid_authenticated)
      end
    end
  end

  def valid_user_role?(role)
    User.roles.key?(role)
  end

  def page_number
    params[:page]
  end

  def filter
    if params[:filter].present?
      params.require(:filter).permit(
        :user_search,
        :sort_by,
        :user_role,
        :user_institution_type,
      )
    end
  end
end
