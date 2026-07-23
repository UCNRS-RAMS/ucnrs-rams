class Manager::Projects::ReservesIndexPresenter < Projects::ReservesIndexPresenter
  def initialize(project:, reserve:)
    super(current_step: 5, project: project)
    @reserve = reserve
  end

  attr_reader :reserve
end
