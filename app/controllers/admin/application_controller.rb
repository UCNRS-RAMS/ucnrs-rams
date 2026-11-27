class Admin::ApplicationController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_admin!

  layout "admin"
end
