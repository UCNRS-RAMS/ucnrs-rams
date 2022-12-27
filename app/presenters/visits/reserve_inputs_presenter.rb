class Visits::ReserveInputsPresenter
  include ActionView::Helpers::TextHelper

  def initialize(reserve)
    @reserve = reserve
  end

  attr_reader :reserve

  delegate_missing_to :reserve

  def alert_message
    if reserve&.reserve_alert_message_enabled
      reserve&.reserve_alert_message
    end
  end

  def alert_message_class
    "reserve-message" if reserve&.reserve_alert_message_enabled
  end
end
