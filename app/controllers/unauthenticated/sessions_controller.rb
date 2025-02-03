module Unauthenticated
  class SessionsController < Devise::SessionsController
    before_action :reset_welcome

    layout "unauthenticated"

    private

    def reset_welcome
      session[:welcome] = nil
    end
  end
end
