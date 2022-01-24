class ProjectPermitAnswerPresenter
  def initialize(project_permit_answer)
    @project_permit_answer = project_permit_answer
  end

  delegate :statement, to: :permit, prefix: true

  delegate_missing_to :project_permit_answer

  private

  attr_reader :project_permit_answer
end
