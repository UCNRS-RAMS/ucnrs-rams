# frozen_string_literal: true

class ProjectShowPresenter
  def initialize(project)
    @project = project
  end

  delegate :id,
    to: :project, prefix: true

  private

  attr_reader :project 
end
