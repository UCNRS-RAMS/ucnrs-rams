module Unauthenticated
  class FailureApp < Devise::FailureApp
    CONFIRMATION_EMAIL_FLASH_KEY = :confirmation_email

    def redirect
      if unconfirmed?
        flash[CONFIRMATION_EMAIL_FLASH_KEY] = request.params.dig(scope.to_s, "email")
      end

      super
    end

    protected

    def redirect_url
      unconfirmed? ? new_user_confirmation_url : super
    end

    private

    def unconfirmed?
      warden_message == :unconfirmed
    end
  end
end
