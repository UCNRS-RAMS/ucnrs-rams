class Manager::Visits::ReportPart1Controller < Manager::ApplicationController
  def self.controller_path
    "manager/visits/report_part_1"
  end

  FISCAL_MONTH_BEGIN = Manager::Reports::ReportBasePresenter::FISCAL_MONTH_BEGIN
  FISCAL_DAY_BEGIN = Manager::Reports::ReportBasePresenter::FISCAL_DAY_BEGIN
  FISCAL_MONTH_END = Manager::Reports::ReportBasePresenter::FISCAL_MONTH_END
  FISCAL_DAY_END = Manager::Reports::ReportBasePresenter::FISCAL_DAY_END

  before_action :authenticate_user!
  before_action :confirm_manager!, unless: -> { super_admin? }

  def show
    @presenter = Manager::Visits::ReportPart1Presenter.new(
      visit: visit,
      fiscal_years_spanned: fiscal_years_spanned,
      selected_fiscal_year_ending: selected_fiscal_year_ending,
      report_part1_data: report_part1_data,
    )
  end

  private

  def visit
    @visit ||= Visit.find(visit_id)
  end

  def report_part1_data
    Reports::ARPart1Query.for_visit(visit, date_begin: fiscal_year_begin_date, date_end: fiscal_year_end_date) ||
      ActiveRecord::Result.empty
  end

  def visit_id
    params.permit(:visit_id).require(:visit_id)
  end

  def visit_span_begin
    visit.user_visits.minimum(:arrives_at)&.to_date || visit.starts_at.to_date
  end

  def visit_span_end
    visit.user_visits.maximum(:departs_at)&.to_date || visit.ends_at.to_date
  end

  def fiscal_years_spanned
    @fiscal_years_spanned ||= (fiscal_year_ending_for(visit_span_begin)..fiscal_year_ending_for(visit_span_end)).to_a
  end

  def selected_fiscal_year_ending
    @selected_fiscal_year_ending ||= begin
      requested = params[:fiscal_year_ending].presence&.to_i
      if requested && fiscal_years_spanned.include?(requested)
        requested
      else
        today_fye = fiscal_year_ending_for(Date.current)
        fiscal_years_spanned.include?(today_fye) ? today_fye : fiscal_years_spanned.max
      end
    end
  end

  def fiscal_year_ending_for(date)
    date.month >= FISCAL_MONTH_BEGIN ? date.year + 1 : date.year
  end

  def fiscal_year_begin_date
    Date.new(selected_fiscal_year_ending - 1, FISCAL_MONTH_BEGIN, FISCAL_DAY_BEGIN)
  end

  def fiscal_year_end_date
    Date.new(selected_fiscal_year_ending, FISCAL_MONTH_END, FISCAL_DAY_END)
  end
end
