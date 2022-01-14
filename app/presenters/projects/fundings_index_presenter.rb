class Projects::FundingsIndexPresenter
  def initialize(current_step:, project:, form: nil)
    @current_step = current_step
    @steps_presenter = StepsPresenter.new(@current_step)
    @project = project
    @form = form || ProjectFundingForm.new(project: project)
  end

  attr_reader :form, :project
  delegate :svg, :step_class, to: :steps_presenter

  def sponsor_options
    Funding.sponsors.map { |key, value| [value, key] }
  end

  private

  attr_reader :steps_presenter, :current_step
end
