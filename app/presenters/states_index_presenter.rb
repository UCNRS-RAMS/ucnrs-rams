class StatesIndexPresenter
  def initialize(country:)
    @country = country
  end

  attr_reader :country

  def states
    State.in_country(country).alphabetical_by_name.map do |state|
      StatePresenter.new(state)
    end
  end
end
