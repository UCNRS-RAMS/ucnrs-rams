class ProjectForm
  include ActiveModel::Model

  attr_reader :project

  def initialize(project = nil)
    @project = project || Project.new
  end

  delegate_missing_to :project

  def model_name
    ActiveModel::Name.new(Project)
  end

  def project_type
    :research
  end

  def save
    false
  end
end
