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
        flash[:notice] = I18n.t(".devise.registrations.flash.updated")
        redirect_to edit_user_registration_path
      else
        flash.now[:error] = I18n.t(".devise.registrations.flash.error")
        render :edit, status: :unprocessable_entity
      end
    end

    protected

    def user_params
      params.require(:user).permit(*User.permitted_registration_attributes)
    end

    private

    def create_user_params
      RegistrationForm.params_with_pending_orcid(user_params, session[REGISTRATION_ORCID_SESSION_KEY].presence)
    end

    def update_user_params
      RegistrationForm.params_with_pending_orcid(user_params, session[REGISTRATION_ORCID_SESSION_KEY].presence)
    end

    def pending_params
      RegistrationForm.params_with_pending_orcid({}, session[REGISTRATION_ORCID_SESSION_KEY].presence)
    end

    def clear_pending_orcid!
      session.delete(REGISTRATION_ORCID_SESSION_KEY)
    end
  end
end
