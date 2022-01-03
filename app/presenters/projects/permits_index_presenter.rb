# frozen_string_literal: true

class Projects::PermitsIndexPresenter
  def initialize(current_step:, project:)
    @current_step = current_step
    @steps_presenter = StepsPresenter.new(@current_step)
    @project = project
  end

  attr_reader :project
  delegate :svg, :step_class, to: :steps_presenter

  private

  attr_reader :steps_presenter, :current_step
end
