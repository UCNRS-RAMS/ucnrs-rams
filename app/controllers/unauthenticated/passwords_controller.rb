module Unauthenticated
  class PasswordsController < Devise::PasswordsController
    layout "unauthenticated"
  end
end
