# frozen_string_literal: true

class Projects::PermitsIndexPresenter
  def initialize(current_step:, project:)
    @current_step = current_step
    @steps_presenter = StepsPresenter.new(@current_step)
    @project = project
  end

  attr_reader :project
  delegate :svg, :step_class, to: :steps_presenter

  def permits_by_authority
    permit_scope
      .map(&method(:wrap_permit_in_presenter))
      .group_by(&:authority)
      .reject { |k, v| v.empty? }
  end

  def has_permits_for_project?
    permit_scope.exists?
  end

  private

  def permit_scope
    Permit
      .in_order
      .for_projects
      .visible
      .matching_project_type(project.project_type)
      .involving_related(project)
  end

  def wrap_permit_in_presenter(permit)
    Projects::PermitPresenter.new(permit)
  end

  attr_reader :steps_presenter, :current_step, :project
end
