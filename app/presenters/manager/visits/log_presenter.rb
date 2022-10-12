# frozen_string_literal: true

class Manager::Visits::LogPresenter
  def initialize(record:)
    @record = record
  end

  delegate_missing_to :record

  def action_name
    if data["about"]
      "#{data["about"]} #{data["about_id"]} #{data["action"]}"
    else
      "#{data["action"]} #{data["about_id"]}"
    end
  end

  def date
    I18n.l(created_at, format: :project_summary_date_time)
  end

  def details
    log
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

  private

  attr_reader :record

  def data
    @data ||= JSON.parse(metadata)
  end
end
