class ProjectsIndexPresenter
  def initialize(user)
    @user = user
  end

  def projects
    Project
      .where(owner: user)
      .order(:created_at)
      .map { |project| ProjectPresenter.new(project) }
  end

  def filter_options
    [
      "All Projects",
      "Active Projects",
      "Incomplete Projects",
      "Inactive Projects",
    ]
  end

  private

  attr_reader :user
end
