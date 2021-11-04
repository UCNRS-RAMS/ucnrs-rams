class Reserves::WaiversIndexPresenter
  def initialize(reserve_waivers:)
    @reserve_waivers = reserve_waivers
  end

  def waivers
    reserve_waivers.map do |waiver|
      WaiverPresenter.new(waiver)
    end
  end

  private

  attr_reader :reserve_waivers
end
