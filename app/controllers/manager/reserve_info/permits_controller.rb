class Manager::ReserveInfo::PermitsController < Manager::ApplicationController
  before_action :authenticate_user!
  before_action :confirm_current_reserve_manager!, unless: -> { super_admin? }
  before_action :is_administrator!, only: [:edit, :update]

  layout "manager"

  def index
    @presenter = Manager::ReserveInfo::PermitsIndexPresenter.new(
      reserve: current_reserve,
    )
  end

  def edit
    form = ReservePermitForm.new(reserve_permit: reserve_permit)
    @presenter = Manager::ReserveInfo::PermitEditPresenter.new(form: form)
  end

  def update
    form = ReservePermitForm.new(reserve_permit: reserve_permit, params: reserve_permit_params)

    if form.save
      redirect_to manager_reserve_reserve_info_permits_path(current_reserve)
    else
      @presenter = Manager::ReserveInfo::PermitEditPresenter.new(form: form)
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def reserve_permit
    @reserve_permit ||= current_reserve.reserve_permits.find(params[:id])
  end

  def reserve_permit_params
    params.require(:reserve_permit).permit(
      :reserve_specific_text,
      :sort_order_override,
      :visible,
      :collect_permit_information,
      :reserve_id_temp,
      :research_project,
      :class_project,
      :public_project,
      :housing_only_project,
      :conference_project,
    )
  end
end
