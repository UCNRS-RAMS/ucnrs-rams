# frozen_string_literal: true

class Manager::Visits::LogPresenter
  include Rails.application.routes.url_helpers

  def initialize(record:, reserve: nil)
    @record = record
    @current_reserve = reserve
  end

  delegate_missing_to :record

  def action_name
    if data["about"]
      "#{data["about"]} #{data["action"]}"
    else
      "#{data["action"]}"
    end
  end

  def date
    I18n.l(created_at, format: :project_summary_date_time)
  end

  def time
    created_at
  end

  def details
    data["details"]
  end

  def user_name
    user ? user.full_name : I18n.t("manager.visits.log.system")
  end

  def old_value
    data["changes"]["ApplicationStatus"].first
  end

  def new_value
    data["changes"]["ApplicationStatus"].last
  end

  def changes
    data["changes"]
  end

  def details_page_url
    case record_type
    when "Visit"
      manager_reserve_visit_log_path(record.record.reserve_id, record_id, id)
    when "Project"
      manager_reserve_visit_log_path(current_reserve, record_id, id)
    else
      "#"
    end
  end

  private

  attr_reader :record, :current_reserve

  def data
    @data ||= JSON.parse(metadata)
  end
end
