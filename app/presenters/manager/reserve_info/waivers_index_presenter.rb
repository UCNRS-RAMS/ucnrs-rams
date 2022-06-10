class Manager::ReserveInfo::WaiversIndexPresenter
  def initialize(reserve:)
    @reserve = reserve
  end

  delegate_missing_to :waivers

  def waivers
    reserve_waivers.map do |waiver|
      WaiverPresenter.new(waiver)
    end
  end

  private

  attr_reader :reserve

  def reserve_waivers
    reserve.waivers
  end
end
