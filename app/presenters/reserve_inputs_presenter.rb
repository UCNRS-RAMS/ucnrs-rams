class ReserveInputsPresenter
  def initialize(reserve)
    @reserve = reserve
  end

  delegate_missing_to :reserve

  def alert_message
    if reserve_alert_message_enabled
      reserve.reserve_alert_message
    end
  end

  private

  attr_reader :reserve
end
