class Projects::FundingsIndexPresenter
  def initialize(current_step:, project:, form: nil)
    @current_step = current_step
    @steps_presenter = StepsPresenter.new(@current_step)
    @project = project
    @form = form || ProjectFundingForm.new(project: project)
  end

  attr_reader :form, :project
  delegate :svg, :step_class, to: :steps_presenter

  def fundings
    fundings_scope.map do |funding|
      Projects::FundingPresenter.new(funding)
    end
  end

  def sponsor_options
    Funding.sponsors.map { |key, value| [value, key] }
  end

  def funding_status_options
    {
      I18n.t("universal.funding.funding_status.is_funded") => :is_funded,
      I18n.t("universal.funding.funding_status.is_submitted") => :is_submitted,
      I18n.t("universal.funding.funding_status.will_be_submitted") => :will_be_submitted,
      I18n.t("universal.funding.funding_status.was_denied") => :was_denied,
    }
  end

  def display_funding_question?
    project.project_type_research?
  end

  private

  attr_reader :steps_presenter, :current_step

  def fundings_scope
    Funding
      .for_project(project)
      .alphabetized
  end
end
