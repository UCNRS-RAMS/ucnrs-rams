module Unauthenticated
  class RegistrationsController < Devise::RegistrationsController
    def new
      @form = RegistrationFormPresenter.new
    end
  end
end
