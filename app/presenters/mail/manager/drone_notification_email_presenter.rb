class Mail::Manager::DroneNotificationEmailPresenter
  def initialize(visit)
    @visit = visit
  end

  attr_reader :visit

  delegate_missing_to :visit
end
