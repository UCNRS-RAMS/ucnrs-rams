class Manager::ReserveInfo::ReserveAddendumsController < ApplicationController
  layout "manager"
  before_action :authenticate_user!
  before_action :confirm_reserve_manager!

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
