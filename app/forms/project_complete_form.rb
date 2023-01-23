class ProjectCompleteForm
  include ActiveModel::Model

  def model_name
    ActiveModel::Name.new(Project)
  end

  attr_reader :project

  def initialize(params: {})
    @project = Project.find_by(id: params[:id])
  end

  def save
    project.update_project_status

    if project.save
      send_email!(project: project) if project.status_before_last_save == "incomplete"
      return true
    end
    false
  end

  private

  def send_email!(project:)
    UserMailer
      .with(presenter: Mail::User::ProjectCompletePresenter.new(project))
      .project_complete
      .deliver_now
  end
end
