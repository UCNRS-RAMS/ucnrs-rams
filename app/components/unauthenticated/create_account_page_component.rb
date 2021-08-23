module Unauthenticated
  class CreateAccountPageComponent < ViewComponent::Base
    attr_reader :user

    def initialize(title:, description:, user: nil)
      @title = title
      @description = description
      @user = user
    end

    renders_one :form, Unauthenticated::CreateAccountFormComponent
  end
end
