# frozen_string_literal: true

class Manager::Visits::ActivityAndNotesIndexPresenter
  DEFAULT_PAGE_LIMIT = 10

  def initialize(visit:, logs_page: 1, notes_page: 1)
    @visit = visit
    @logs_page = logs_page
    @notes_page = notes_page
  end

  attr_reader :visit, :logs_page, :notes_page
  delegate_missing_to :visit

  def logs
    logs_scope.map do |record|
      Manager::Visits::ActivityPresenter.new(record: record)
    end
  end

  def notes
    notes_scope.map do |record|
      Manager::Visits::VisitNotePresenter.new(record: record)
    end
  end

  def logs_scope
    visit.logs.or(visit.project.logs)
      .includes(:user)
      .page(logs_page)
      .per(DEFAULT_PAGE_LIMIT)
  end

  def notes_scope
    visit
      .reserve_notes
      .includes(:user)
      .page(notes_page)
      .per(DEFAULT_PAGE_LIMIT)
  end
end
