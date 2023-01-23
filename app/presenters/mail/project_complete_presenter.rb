# frozen_string_literal: true

class Mail::ProjectCompletePresenter
  def initialize(project)
    @project = ProjectShowPresenter.new(project)
  end

  attr_reader :project

  delegate_missing_to :project

  def project_name
    title
  end
end
