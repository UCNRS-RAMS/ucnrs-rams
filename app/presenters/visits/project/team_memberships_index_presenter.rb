class Visits::Project::TeamMembershipsIndexPresenter < Projects::TeamMembershipsIndexPresenter
  def initialize(current_step:, visit: nil, form: nil, current_user: nil)
    @visit = visit
    super(
      current_step: 2,
      project: visit.project,
      current_user: current_user,
      form: form,
    )

  end

  attr_reader :visit
end
