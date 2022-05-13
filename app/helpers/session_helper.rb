module SessionHelper
  def current_reserve
    @current_reserve ||= Reserve.select(:id, :name, :managing_campus_id).eager_load(:managing_campus).find_by(id: params[:reserve_id])
  end
end
