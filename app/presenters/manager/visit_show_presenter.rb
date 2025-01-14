# frozen_string_literal: true

class Manager::VisitShowPresenter
  def initialize(visit:, current_user:, selected_tab: nil)
    @visit = VisitPresenter.new(visit)
    @user = current_user
    @selected_tab = selected_tab
  end

  delegate_missing_to :visit

  attr_reader :visit, :user, :selected_tab

  def status_classes
    "btn-status bg-#{status_class}"
  end

  def tab_content_path
    case selected_tab
    when "details"
      edit_manager_reserve_visit_detail_path(reserve_id: reserve_id, visit_id: id)
    when "visitors"
      manager_reserve_visit_user_visits_path(visit_id: id, reserve_id: reserve_id)
    when "reserve_info"
      manager_reserve_visit_reserve_info_index_path(reserve_id: reserve_id, visit_id: id)
    when "activity"
      manager_reserve_visit_activity_and_notes_path(visit_id: id, reserve_id: reserve_id)
    when "invoices"
      manager_reserve_visit_invoices_path(visit_id: id, reserve_id: reserve_id)
    else
      manager_reserve_visit_summary_path(reserve_id: reserve_id, visit_id: id)
    end
  end

  def tab_class(tab = nil)
    selected_tab == tab ? "active" : ""
  end

  def tab_params(id: "summary", path: "#", classes: "", action_method: "changeTab", name: nil, clickable: true )
    {
      id: id,
      name: name || I18n.translate("manager.visits.tab.#{id}"),
      path: path,
      classes: "nav-link #{classes}#{" disabled-link" unless clickable}",
      action_method: action_method,
      clickable: clickable
    }
  end

  def reserve_manager?
    user.admin_or_manage_reserve?(visit.reserve)
  end

  def btn_class
    "disabled-link" unless reserve_manager?
  end

  def visit_date_range
    if starts_at.present? && ends_at.present?
      DateRangePresenter.new(
        start_date: starts_at,
        end_date: ends_at,
      ).value("date_range.different_years")
    else
      not_applicable
    end
  end

  private

  def not_applicable
    I18n.t("not_applicable")
  end
end
