module Unauthenticated
  class ForgotPasswordComponent < ViewComponent::Base
    def initialize(user)
      @user = user
    end

    def resource
      @user
    end

    def resource_name
      devise_mapping.name
    end

    def resource_cass
      devise_mapping.to
    end

    def devise_mapping
      Devise.mappings[:user]
    end
  end
end
