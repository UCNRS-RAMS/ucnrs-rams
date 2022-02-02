# frozen_string_literal: true

class Projects::QuestionsIndexPresenter
  def initialize(current_step:, project:, form: nil)
    @current_step = current_step
    @steps_presenter = StepsPresenter.new(@current_step)
    @project = project
    @form = form || ProjectPermitAnswersForm.new(project: project)
  end

  attr_reader :form, :project
  delegate :svg, :step_class, to: :steps_presenter

  def questions_by_authority
    permit_scope
      .map(&method(:wrap_question_in_presenter))
      .group_by(&:authority)
      .reject { |k, v| v.empty? }
  end

  def has_questions_for_project?
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
      .include_answers_for(project)
  end

  def wrap_question_in_presenter(question)
    Projects::PermitPresenter.new(question, form: form.answer_form(question.id))
  end

  attr_reader :steps_presenter, :current_step
end
