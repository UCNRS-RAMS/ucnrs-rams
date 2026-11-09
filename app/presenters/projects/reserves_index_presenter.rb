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

  def interested_in?(reserve)
    interested_reserve_ids.include?(reserve.id)
  end

  private

  attr_reader :steps_presenter, :current_step

  def interested_reserve_ids
    @interested_reserve_ids ||= project.reserve_interests.pluck(:reserve_id)
  end
end
