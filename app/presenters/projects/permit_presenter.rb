class Projects::PermitPresenter
  def initialize(permit)
    @permit = permit
  end

  delegate_missing_to :permit

  private

  attr_reader :permit
end
