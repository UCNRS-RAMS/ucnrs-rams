class Unauthenticated::PasswordsController < Devise::PasswordsController
  layout "unauthenticated"
end
