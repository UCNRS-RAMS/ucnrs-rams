# frozen_string_literal: true

class ReservePermitPresenter
  CHECK_ICON = "check.svg".freeze
  UNCHECK_ICON = "dot.svg".freeze
  ICON_TO_ALT = {
      CHECK_ICON => "alt.checked",
      UNCHECK_ICON => "alt.unchecked",
    }.freeze

  def initialize(reserve_permit)
    @reserve_permit = reserve_permit
  end

  delegate :question,
    :description,
    to: :permit, prefix: true

  delegate :permit, to: :reserve_permit

  delegate_missing_to :reserve_permit

  def icon(for_column)
    if for_column == true
      CHECK_ICON
    else
      UNCHECK_ICON
    end
  end

  def icon_alt_i18n_key(for_column)
    ICON_TO_ALT[icon(for_column)]
  end

  private

  attr_reader :reserve_permit
  
end
