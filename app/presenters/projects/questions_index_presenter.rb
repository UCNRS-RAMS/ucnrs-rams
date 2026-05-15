# frozen_string_literal: true

class Projects::QuestionsIndexPresenter
  include Rails.application.routes.url_helpers

  def initialize(current_step:, project:, form: nil)
    @current_step = current_step
    @steps_presenter = StepsPresenter.new(@current_step)
    @project = project
    @form = form || ProjectAnswersForm.new(project: project)
  end

  attr_reader :form, :project
  delegate :svg, :step_class, to: :steps_presenter
  delegate :id, to: :project

  def questions_by_authority
    permit_scope
      .map(&method(:wrap_question_in_presenter))
      .group_by(&:authority)
      .reject { |_k, v| v.empty? }
  end

  def questions_by_reserve
    reserve_question_scope
      .map(&method(:wrap_question_in_presenter))
      .group_by(&:reserve_name)
      .reject { |_k, v| v.empty? }
  end

  def has_permit_questions_for_project?
    permit_scope.exists?
  end

  def has_reserve_questions_for_project?
    reserve_question_scope.exists?
  end

  def form_url
    project_answers_path(project.id)
  end

  private

  def permit_scope
    Permit
      .in_order
      .for_projects
      .visible
      .matching_project_type(project.project_type)
      .involving_related(project)
      .include_answers_for(project)
  end

  def reserve_question_scope
    ReserveQuestion
      .in_order
      .for_projects
      .visible
      .includes([:reserve])
      .with_answers_for_project(project)
  end

  def wrap_question_in_presenter(question)
    if question.is_a?(Permit)
      Projects::PermitPresenter.new(question)
    else
      Projects::QuestionPresenter.new(question)
    end
  end

  attr_reader :steps_presenter, :current_step
end
