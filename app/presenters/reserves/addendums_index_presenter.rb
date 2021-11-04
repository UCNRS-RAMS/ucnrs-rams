class Reserves::AddendumsIndexPresenter
  def initialize(addendums:)
    @addendums = addendums
  end

  def reserve_addendums
    addendums.map do |addendum|
      ReserveAddendumPresenter.new(addendum)
    end
  end

  private

  attr_reader :addendums
end
