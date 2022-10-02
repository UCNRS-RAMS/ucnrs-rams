class Manager::Reports::ReportPart2Presenter
  def initialize(form: nil, reserve: nil)
    @form = form
    @reserve = reserve
  end

  delegate :annual_report, to: :form, prefix: true

  delegate :fiscal_year_ending, to: :form_annual_report

  attr_reader :form

  def report_part2_data
    report_part2_data_scope
      .map{ |institution| InstitutionPresenter.new(institution) }
      .group_by(&:institution_type)
  end

  def fiscal_year
    "#{fiscal_year_ending - 1}-#{fiscal_year_ending}"
  end

  def fiscal_year_ending_options
    [].tap do |arr|
      (2000..(Date.current.year + 1)).each { |year_end| arr << ["#{year_end - 1}-#{year_end}", year_end] }
    end
  end

  def fiscal_year_select_path
    :report_part_2_manager_reserve_report_path
  end

  def annual_report_column
    :part_2_approved
  end

  def report_part2_data_scope
    Institution
      .joins(:user_visits)
      .merge(
        UserVisit
          .at_reserve(@reserve)
          .approved_status
          .having_between_time(date_start: start_date, date_end: stop_date)
          .joins(:visit)
          .merge(
            Visit.where(report_access: true)
          )
      )
      .group(:id)
      .order(:institution_type, :name)
      .includes([:state, :country])
  end

  private

  def start_date
    Date.new(fiscal_year_ending - 1, 7, 1)
  end

  def stop_date
    Date.new(fiscal_year_ending, 6, 30)
  end
end
