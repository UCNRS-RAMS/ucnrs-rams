# frozen_string_literal: true

class Manager::Reports::ReportPart8::ProjectPresenter
  def initialize(project)
    @project = project
  end

  attr_reader :project

  delegate :role,
    :institution,
    to: :owner, prefix: true

  delegate_missing_to :project

  def owner
    UserPresenter.new(project.owner)
  end
end
