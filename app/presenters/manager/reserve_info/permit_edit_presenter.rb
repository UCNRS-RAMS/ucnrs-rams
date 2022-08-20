# frozen_string_literal: true

class Manager::ReserveInfo::PermitEditPresenter
  def initialize(form:)
    @form = form
  end

  attr_reader :form

  delegate :reserve_permit, to: :form, prefix: true
  delegate :permit_question,
    :permit_description,
    to: :editing_reserve_permit

  private

  def editing_reserve_permit
    ReservePermitPresenter.new(form.reserve_permit)
  end
end
