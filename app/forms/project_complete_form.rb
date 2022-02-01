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
    project.save
  end
end
