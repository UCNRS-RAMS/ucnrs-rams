class Manager::ReserveInfo::DirectionsController < Manager::ApplicationController
  before_action :authenticate_user!
  before_action :confirm_current_reserve_manager!, unless: -> { super_admin? }
  before_action :is_administrator!, only: [:update], unless: -> { super_admin? }

  layout "manager"

  def edit
    form = ReserveForm.new(reserve: current_reserve)
    @presenter = Manager::ReserveInfo::DirectionsEditPresenter.new(
      reserve: current_reserve,
      form: form,
    )
  end

  def update
    form = ReserveForm.new(
      reserve: current_reserve,
      params: directions_params,
    )
    @presenter = Manager::ReserveInfo::DirectionsEditPresenter.new(
      reserve: current_reserve,
      form: form,
    )

    if form.save
      flash.now[:notice] = "Update success."
      render :edit
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def directions_params
    params.require(:reserve).permit(
      :directions
    )
  end
end
