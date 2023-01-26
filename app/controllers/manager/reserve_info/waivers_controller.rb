class Manager::ReserveInfo::WaiversController < Manager::ManagerController
  layout "manager"
  before_action :authenticate_user!
  before_action :confirm_reserve_manager!
  before_action :is_administrator!, only: [:update]

  def index
    @presenter = Manager::ReserveInfo::WaiversIndexPresenter.new(
      reserve: current_reserve,
    )
  end

  def edit
    form = WaiverForm.new(waiver: waiver)
    @presenter = Manager::ReserveInfo::WaiverEditPresenter.new(form: form)
  end

  def update
    form = WaiverForm.new(waiver: waiver, params: waiver_params)

    if form.save
      redirect_to manager_reserve_reserve_info_waivers_path(current_reserve)
    else
      @presenter = Manager::ReserveInfo::WaiverEditPresenter.new(form: form)
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def waiver
    @waiver ||= Waiver.find(params[:id])
  end

  def waiver_params
    params.require(:waiver).permit(
      :id,
      :name,
      :description,
      :url,
    )
  end
end
