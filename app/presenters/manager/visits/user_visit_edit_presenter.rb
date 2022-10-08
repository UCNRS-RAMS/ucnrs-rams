# frozen_string_literal: true

class Manager::Visits::UserVisitEditPresenter < Visits::UserVisitEditPresenter
  def editing_user_visit
    @editing_user_visit ||= Manager::Visits::UserVisitPresenter.new(
      form.user_visit,
    )
  end

  def user_days_partial
    "manager/visits/user_visits/user_days"
  end

  def user_visit_form_path
    manager_reserve_user_visit_path(visit.reserve_id, id)
  end

  def manual_days_same_as_calculated?
    actual_days = "%0.2f" % form.actual_days
    user_days == actual_days.to_i
  end

  def user_days_description
    I18n.t("manager.visits.user_visits.user_days_description",
      total_days: total_days, count: count, user_days: user_days)
  end

  private

  def user_days
    total_days * count
  end
end
