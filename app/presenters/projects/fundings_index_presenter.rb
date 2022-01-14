class Projects::FundingsIndexPresenter
  def initialize(current_step:, project:)
    @current_step = current_step
    @steps_presenter = StepsPresenter.new(@current_step)
    @project = project
  end

  attr_reader :project
  delegate :svg, :step_class, to: :steps_presenter

  def sponsor_options
    [
      "National Science Foundation (NSF)",
      "National Institute of Health (NIH)",
      "U.S. Geological Survey (USGS)",
      "U.S. Forest Service (USFS)",
      "U.S. Department of Agriculture (USDA)",
      "California Department of Fish and Wildlife",
      "Other"
    ]
  end

  private

  attr_reader :steps_presenter, :current_step
end
