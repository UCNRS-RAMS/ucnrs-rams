# frozen_string_literal: true

class Manager::VisitShowPresenter
  def initialize(visit:, current_user:)
    @visit = VisitPresenter.new(visit)
    @user = current_user
  end

  delegate_missing_to :visit

  attr_reader :visit, :user

  def status_classes
    "btn-status bg-#{status_class}"
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
    user.manager_of_reserve?(reserve)
  end

  def btn_class
    "disabled-link" unless reserve_manager?
  end

  def visit_date_range
    DateRangePresenter.new(
      start_date: starts_at,
      end_date: ends_at,
    ).value("date_range.different_years")
  end
end
