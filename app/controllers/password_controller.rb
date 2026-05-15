class PasswordController < Devise::PasswordsController
  before_action :authenticate_user!

  def new
    @user = current_user
  end

  def create
    User.send_reset_password_instructions({ email: user.email })

    if params[:user_id].present?
      flash.now[:notice] = I18n.t(".password.create.reset_password_sent")
    else
      sign_out user
    end
  end

  private

  def user
    @user ||=  params[:user_id].present? ? User.find_by(id: params[:user_id]) : current_user
  end

end
