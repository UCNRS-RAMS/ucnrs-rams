class Manager::Reports::ReportPart3Presenter
  FISCAL_MONTH_BEGIN = 7
  FISCAL_DAY_BEGIN = 1
  FISCAL_MONTH_END = 6
  FISCAL_DAY_END = 30

  def initialize(form: nil)
    @form = form
  end

  attr_reader :form

  delegate :annual_report, to: :form, prefix: true
  delegate :fiscal_year_ending, :reserve_id, to: :form_annual_report

  def report_part3_data
    report_part3_data_scope
      .map{ |project| ProjectPresenter.new(project: project) }
      .group_by(&:institution_type)
      .each_with_object({}) do |(institution_type, projects), hash|
        hash[institution_type] = projects.group_by(&:institution_name)
      end
  end

  def report_part3_data_scope
    Project
      .select("projects.*, institutions.institution_type, institutions.name AS institution_name")
      .of_type("class")
      .joins(:visits, owner: :institution)
      .merge(
        Visit
          .by_reserve(reserve_id)
          .with_report_access(true)
          .joins(:user_visits)
          .merge(
              UserVisit
                .having_between_time(date_start: start_date, date_end: stop_date)
                .where(status: :approved)
            )
      )
      .group(:id)
      .order(
        Institution.arel_table[:institution_type],
        Institution.arel_table[:name],
        Project.arel_table[:course_title]
      )
      .includes([:owner])
  end

  def fiscal_year
    "#{fiscal_year_ending - 1}-#{fiscal_year_ending}"
  end

  def fiscal_year_ending_options
    (2000..(Date.current.year + 1)).map { |year_end| ["#{year_end - 1}-#{year_end}", year_end] }
  end

  def fiscal_year_select_path
    :report_part_3_manager_reserve_report_path
  end

  def annual_report_column
    :part_3_approved
  end

  def project_user_details(project)
    UserVisit
      .joins(:visits)
      .merge(
        Visit
          .where(project: project)
      )
  end

  private

  def start_date
    Date.new(fiscal_year_ending - 1, FISCAL_MONTH_BEGIN, FISCAL_DAY_BEGIN)
  end

  def stop_date
    Date.new(fiscal_year_ending, FISCAL_MONTH_END, FISCAL_DAY_END)
  end
end
