class Projects::TeamsEditPresenter
  def initialize(user:, current_step:, project: nil)
    @user = user
    @project = project
    @current_step = current_step
    @steps_presenter = StepsPresenter.new(@current_step)
  end

  attr_reader :project
  delegate :svg, :step_class, to: :steps_presenter

  private

  attr_reader :user, :steps_presenter, :current_step
end
