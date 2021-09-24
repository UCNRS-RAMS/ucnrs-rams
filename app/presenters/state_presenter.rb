class StatePresenter
  def initialize(state)
    @state = state
  end

  attr_reader :state

  delegate :id, :name, to: :state
end
