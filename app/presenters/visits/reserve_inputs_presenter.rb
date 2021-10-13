class Visits::ReserveInputsPresenter
  def initialize(reserve)
    @reserve = reserve
  end

  attr_reader :reserve

  delegate_missing_to :reserve

  def alert_message
    if reserve_alert_message_enabled
      reserve_alert_message
    end
  end
end
