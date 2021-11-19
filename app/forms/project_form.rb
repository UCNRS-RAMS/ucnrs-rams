class ProjectForm
  include ActiveModel::Model

  def model_name
    ActiveModel::Name.new(Project)
  end

  def project_type
    :research
  end
end
