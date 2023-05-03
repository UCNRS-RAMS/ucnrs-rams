class Reserves::AddendumsIndexPresenter
  def initialize(reserve:, addendums:)
    @reserve = reserve
    @addendums = addendums
  end

  def reserve_addendums
    addendums.map do |addendum|
      ReserveAddendumPresenter.new(addendum)
    end
  end

  private

  attr_reader :reserve, :addendums
end
