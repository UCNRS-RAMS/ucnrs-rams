module Unauthenticated
  class SessionsController < Devise::SessionsController
    layout "unauthenticated"
  end
end
