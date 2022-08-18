# frozen_string_literal: true

class Manager::ReserveInfo::StaffAndNotificationNewPresenter
  def initialize(form:)
    @form = form
  end

  attr_reader :form

  delegate :reserve_personnel, to: :form, prefix: true
end
