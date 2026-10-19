module Unauthenticated
  class ConfirmationsController < Devise::ConfirmationsController
    layout "unauthenticated"

    def new
      self.resource = resource_class.new(email: flash[FailureApp::CONFIRMATION_EMAIL_FLASH_KEY])
    end
  end
end
