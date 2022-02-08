class ProjectPermitAnswerPresenter
  def initialize(project_permit_answer)
    @project_permit_answer = project_permit_answer
  end

  delegate :permit, to: :project_permit_answer
  delegate :statement, :question, to: :permit

  delegate_missing_to :project_permit_answer

  def permit_statement
    statement || question
  end

  private

  attr_reader :project_permit_answer
end
