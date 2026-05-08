module VisitScopedToReserve
  extend ActiveSupport::Concern

  private

  def confirm_visit_in_reserve!
    return true if visit.reserve_id == current_reserve.id

    respond_to_modal_turbo_frame(
      flash_msg: I18n.translate(
        "manager.permission.visit_not_in_reserve",
        id: visit.id,
        reserve: current_reserve.name,
      ),
    )
  end
end
