module Unauthenticated
  class ConfirmationsController < Devise::ConfirmationsController
    layout "unauthenticated"
  end
end
