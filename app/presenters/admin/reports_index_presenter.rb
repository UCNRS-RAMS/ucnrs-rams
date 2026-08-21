# frozen_string_literal: true

class Admin::ReportsIndexPresenter
  CHECK_ICON = "check.svg".freeze
  FIRST_FISCAL_YEAR_ENDING = 2015
  RESERVE_IDS = (1..100).freeze
  UNCHECK_ICON = "dot.svg".freeze
  ICON_TO_ALT = {
    CHECK_ICON => "alt.checked",
    UNCHECK_ICON => "alt.unchecked",
  }.freeze

  def initialize(fiscal_year_ending: nil)
    @requested_fiscal_year_ending = fiscal_year_ending
  end

  def annual_reports
    @annual_reports ||= AnnualReport
      .where(reserve: RESERVE_IDS, fiscal_year_ending: designated_fiscal_year_ending)
      .includes(:reserve)
      .references(:reserve)
      .order("reserves.pulldown_name")
  end

  def labeled_designated_fiscal_year
    fiscal_year_label(designated_fiscal_year_ending)
  end

  def designated_fiscal_year_ending
    @designated_fiscal_year_ending ||=
      if available_fiscal_year_endings.include?(requested_fiscal_year_ending.to_i)
        requested_fiscal_year_ending.to_i
      else
        default_fiscal_year_ending
      end
  end

  def fiscal_year_ending_options
    available_fiscal_year_endings.map { |year_ending| [fiscal_year_label(year_ending), year_ending] }
  end

  def icon_alt_i18n_key(approved)
    ICON_TO_ALT[icon_for_column(approved)]
  end

  def icon_for_column(approved)
    approved ? CHECK_ICON : UNCHECK_ICON
  end

  private

  attr_reader :requested_fiscal_year_ending

  def default_fiscal_year_ending
    Date.current.year
  end

  def available_fiscal_year_endings
    default_fiscal_year_ending.downto(FIRST_FISCAL_YEAR_ENDING).to_a
  end

  def fiscal_year_label(year_ending)
    "#{year_ending - 1}-#{year_ending}"
  end
end
