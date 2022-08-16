class Manager::ReserveInfo::StaffAndNotificationsController < ApplicationController
  layout "manager"
  before_action :authenticate_user!
  before_action :confirm_manager!

  def index
    @presenter = Manager::ReserveInfo::StaffAndNotificationsIndexPresenter.new(
      reserve: current_reserve,
    )
  end

  def edit
    form = ReservePersonnelForm.new(reserve_personnel: reserve_personnel)
    @presenter = Manager::ReserveInfo::StaffAndNotificationEditPresenter.new(form: form)
  end

  def update
    form = ReservePersonnelForm.new(reserve_personnel: reserve_personnel, params: reserve_personnel_params)
    
    if form.save
      redirect_to manager_reserve_reserve_info_staff_and_notifications_path(current_reserve)
    else
      @presenter = Manager::ReserveInfo::StaffAndNotificationEditPresenter.new(form: form)
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def reserve_personnel
    @reserve_personnel ||= current_reserve.personnel.find(params[:id])
  end

  def reserve_personnel_params
    params.require(:reserve_personnel).permit(
      :id,
      :reserve_id,
      :user_id,
      :supervisor_name,
      :receive_project_email,
      :receive_invoice_email,
      :receive_update_email,
      :receive_iacuc_email,
      :receive_incomplete_visit_email,
      :receive_approval_email,
      :receive_drone_email,
      :receive_scuba_email,
      :receive_new_project_email,
      :receive_new_visit_email,
      :phone_number,
      :email,
    )
  end
end
