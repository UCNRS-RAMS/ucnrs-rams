# frozen_string_literal: true

class Manager::Reports::ShowPresenter
  CHECK_ICON = "check.svg".freeze
  UNCHECK_ICON = "dot.svg".freeze
  ICON_TO_ALT = {
    CHECK_ICON => "alt.checked",
    UNCHECK_ICON => "alt.unchecked",
  }.freeze

  def initialize(annual_report: nil)
    @annual_report = annual_report
  end

  attr_reader :annual_report

  delegate_missing_to :annual_report

  def fiscal_year
    "#{fiscal_year_ending - 1}-#{fiscal_year_ending}"
  end

  def fiscal_year_ending_options
    [].tap do |arr|
      (2000..(Date.current.year + 1)).each { |year_end| arr << ["#{year_end - 1}-#{year_end}", year_end] }
    end
  end

  def fiscal_year_select_path
    :manager_reserve_report_path
  end

  def icon_for_column(column)
    if column == true
      CHECK_ICON
    else
      UNCHECK_ICON
    end
  end

  def icon_alt_i18n_key(column)
    ICON_TO_ALT[icon_for_column(column)]
  end
end
