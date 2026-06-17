class Projects::ReservesIndexPresenter
  def initialize(current_step:, project:)
    @current_step = current_step
    @steps_presenter = StepsPresenter.new(@current_step)
    @project = project
  end

  attr_reader :project
  delegate :svg, :step_class, to: :steps_presenter
  delegate :project_type, to: :project

  def reserves
    Reserve.alphabetized
  end

  private

  attr_reader :steps_presenter, :current_step
end
