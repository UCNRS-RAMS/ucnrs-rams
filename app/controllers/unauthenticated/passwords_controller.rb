module Unauthenticated
  class PasswordsController < Devise::PasswordsController
    layout "unauthenticated"

    def index
      render(ForgotPasswordComponent.new(current_user))
    end
  end
end
