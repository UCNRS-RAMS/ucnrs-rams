# frozen_string_literal: true

class Manager::Visits::UserVisitPresenter < Visits::UserVisitPresenter
  def visit_user_visit_form_path
    manager_reserve_visit_user_visit_path(visit.reserve_id, visit_id, id)
  end

  def edit_user_visit_form_path
    edit_manager_reserve_user_visit_path(visit.reserve_id, id)
  end

  def date_range
    super + I18n.t("manager.visits.user_visits.total_days", total_days: total_days)
  end

  def total_days
    ((departs_at.to_date + 1.day) - arrives_at.to_date).to_i
  end
end
