# frozen_string_literal: true

class Manager::Projects::ReserveNotePresenter
  def initialize(record:)
    @record = record
  end

  delegate_missing_to :record

  def action_name
    action
  end

  def date
    I18n.l(created_at, format: :project_summary_date_time)
  end

  def message
    note
  end

  def user_name
    user.full_name
  end

  private

  attr_reader :record
end
