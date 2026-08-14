module Unauthenticated
  class RegistrationsController < Devise::RegistrationsController
    REGISTRATION_ORCID_SESSION_KEY = :registration_orcid_identifier

    def new
      @form = RegistrationForm.new(params: pending_params)
      clear_pending_orcid!
      @presenter = RegistrationFormPresenter.new(@form)
    end

    def create
      @form = RegistrationForm.new(params: create_user_params)
      if @form.submit
        clear_pending_orcid!
        flash[:success] = I18n.t(".devise.registrations.create.success")
        redirect_to root_path
      else
        flash.now[:error] = I18n.t(".devise.registrations.create.failure")
        @presenter = RegistrationFormPresenter.new(@form)
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @form = RegistrationForm.new(user: current_user, params: pending_params)
      clear_pending_orcid!
      @presenter = RegistrationFormPresenter.new(@form)
    end

    def update
      @form = RegistrationForm.new(user: current_user, params: update_user_params)
      @presenter = RegistrationFormPresenter.new(@form)

      if @form.submit
        clear_pending_orcid!
        flash.now[:notice] = I18n.t(".devise.registrations.flash.updated")
        render :edit
      else
        flash.now[:error] = I18n.t(".devise.registrations.flash.error")
        render :edit, status: :unprocessable_entity
      end
    end

    protected

    def user_params
      params.require(:user).permit(
        :role,
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
        :orcid_authenticated,
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
    end

    private

    def create_user_params
      RegistrationForm.params_with_pending_orcid(user_params, session[REGISTRATION_ORCID_SESSION_KEY].presence)
    end

    def update_user_params
      RegistrationForm.params_with_pending_orcid(user_params, session[REGISTRATION_ORCID_SESSION_KEY].presence)
    end

    def pending_orcid_params
      RegistrationForm.params_with_pending_orcid({}, session[REGISTRATION_ORCID_SESSION_KEY].presence)
    end

    def clear_pending_orcid!
      session.delete(REGISTRATION_ORCID_SESSION_KEY)
    end
  end
end
