# frozen_string_literal: true

class Manager::Projects::ActivityAndNotesIndexPresenter
  DEFAULT_PAGE_LIMIT = 10

  def initialize(project:, logs_page: 1, notes_page: 1)
    @project = project
    @logs_page = logs_page
    @notes_page = notes_page
  end

  attr_reader :project, :logs_page, :notes_page
  delegate_missing_to :project

  def logs
    logs_scope.map do |record|
      Manager::Projects::ActivityPresenter.new(record: record)
    end
  end

  def notes
    notes_scope.map do |record|
      Manager::Projects::ReserveNotePresenter.new(record: record)
    end
  end

  def logs_scope
    project
      .logs
      .includes(:user)
      .page(logs_page)
      .per(DEFAULT_PAGE_LIMIT)
  end

  def notes_scope
    project
      .reserve_notes
      .includes(:user)
      .page(notes_page)
      .per(DEFAULT_PAGE_LIMIT)
  end
end
