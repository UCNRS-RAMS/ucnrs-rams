class ProjectsIndexPresenter
  def initialize(user)
    @user = user
  end

  def projects
    Project
      .with_active_team_member(user)
      .recent_first
      .limit(10)
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
