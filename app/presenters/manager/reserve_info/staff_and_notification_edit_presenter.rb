# frozen_string_literal: true

class Manager::ReserveInfo::StaffAndNotificationEditPresenter
  def initialize(form:)
    @form = form
  end

  attr_reader :form

  delegate :reserve_personnel, to: :form, prefix: true

  def editing_reserve_personnel
    @editing_reserve_personnel ||= ReservePersonnelPresenter.new(
      form_reserve_personnel
    )
  end

  def reserve_personnel_id
    editing_reserve_personnel.id
  end

  def reserve_personnel_name
    editing_reserve_personnel.full_name
  end
end
