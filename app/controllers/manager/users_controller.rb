class Manager::UsersController < Manager::ApplicationController
  before_action :authenticate_user!
  before_action :confirm_current_reserve_manager!, unless: -> { super_admin? }

  layout "manager"

  def index
    @presenter = Manager::UsersIndexPresenter.new(
      page: page_number,
      filter: filter,
    )
  end

  def edit
    form = RegistrationForm.new(user: user)
    @presenter = Manager::UserEditPresenter.new(form)
  end

  def update
    form = RegistrationForm.new(user: user, params: user_params)
    @presenter = Manager::UserEditPresenter.new(form)

    if form.submit
      flash.now[:notice] = I18n.t(".devise.registrations.flash.updated")
      render :edit
    else
      flash.now[:error] = I18n.t(".devise.registrations.flash.error")
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user
    @user ||= User.find(params[:id])
  end


  def user_params
    params.require(:user).permit(*User.permitted_registration_attributes)
  end

  def page_number
    params[:page]
  end

  def filter
    if params[:filter].present?
      params.require(:filter).permit(
        :user_search,
        :sort_by,
        :user_role,
        :user_institution_type,
      )
    end
  end
end
