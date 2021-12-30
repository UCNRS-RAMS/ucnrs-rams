class PasswordController < Devise::PasswordsController
  before_action :authenticate_user!

  def new
    @user = current_user
  end

  def create
    @user = current_user
    User.send_reset_password_instructions({ email: @user.email })
    sign_out @user
  end
end
