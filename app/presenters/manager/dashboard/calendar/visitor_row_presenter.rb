# frozen_string_literal: true

class Manager::Dashboard::Calendar::VisitorRowPresenter < Visits::UserVisitPresenter
  def initials
    name
      .split
      .first(2)
      .filter_map { |word| word[/[[:alpha:]]/] }
      .join
      .upcase
  end

  def name
    user_full_name
  end

  def role_label
    UserVisit.roles[role]
  end

  def arrives_label
    short_datetime(arrives_at)
  end

  def departs_label
    short_datetime(departs_at)
  end

  private

  def short_datetime(datetime)
    I18n.l(datetime, format: :calendar_short_datetime) if datetime.present?
  end
end
