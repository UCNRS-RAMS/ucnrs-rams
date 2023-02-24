class Manager::ReserveInfo::ReserveAddendumsController < Manager::ApplicationController
  before_action :authenticate_user!
  before_action :confirm_current_reserve_manager!, unless: -> { super_admin? }
  before_action :is_administrator!, only: [:new, :create, :edit, :update, :destroy]

  layout "manager"

  def index
    @presenter = Manager::ReserveInfo::ReserveAddendumsIndexPresenter.new(
      reserve: current_reserve,
    )
  end

  def new
    form = ReserveAddendumForm.new
    @presenter = Manager::ReserveInfo::ReserveAddendumNewPresenter.new(form: form)
  end

  def create
    form = ReserveAddendumForm.new(params: reserve_addendum_params.merge(reserve_id: current_reserve.id))

    if form.save
      redirect_to manager_reserve_reserve_info_reserve_addendums_path(current_reserve)
    else
      @presenter = Manager::ReserveInfo::ReserveAddendumNewPresenter.new(form: form)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    form = ReserveAddendumForm.new(reserve_addendum: reserve_addendum)
    @presenter = Manager::ReserveInfo::ReserveAddendumEditPresenter.new(form: form)
  end

  def update
    form = ReserveAddendumForm.new(reserve_addendum: reserve_addendum, params: reserve_addendum_params)

    if form.save
      redirect_to manager_reserve_reserve_info_reserve_addendums_path(current_reserve)
    else
      @presenter = Manager::ReserveInfo::ReserveAddendumEditPresenter.new(form: form)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if reserve_addendum.destroy
      redirect_to manager_reserve_reserve_info_reserve_addendums_path(current_reserve)
    else
      redirect_to manager_reserve_reserve_info_reserve_addendums_path(current_reserve), status: :unprocessable_entity
    end
  end

  private

  def reserve_addendum
    @reserve_addendum ||= current_reserve.addendums.find(params[:id])
  end

  def reserve_addendum_params
    params.require(:reserve_addendum).permit(
      :id,
      :sort_order,
      :name,
      :content,
    )
  end
end
