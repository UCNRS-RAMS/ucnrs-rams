# frozen_string_literal: true

class Mail::ProjectQuestionsPresenter
  def initialize(project:)
    @project = project
  end

  attr_reader :project
  delegate :id, to: :project

  def permit_questions_by_authority
    permit_scope
      .map(&method(:wrap_question_in_presenter))
      .group_by(&:authority)
      .reject { |_k, v| v.empty? }
  end

  def reserve_questions_by_reserve
    reserve_question_scope
      .map(&method(:wrap_question_in_presenter))
      .group_by(&:reserve_name)
      .reject { |_k, v| v.empty? }
  end

  def have_permit_questions_for_project?
    permit_scope.exists?
  end

  def have_reserve_questions_for_project?
    reserve_question_scope.exists?
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
      Mail::PermitPresenter.new(question)
    else
      Mail::QuestionPresenter.new(question)
    end
  end
end
