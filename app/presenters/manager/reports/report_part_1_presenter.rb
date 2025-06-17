class Manager::Reports::ReportPart1Presenter
  FISCAL_MONTH_BEGIN = 7
  FISCAL_DAY_BEGIN = 1
  FISCAL_MONTH_END = 6
  FISCAL_DAY_END = 30

  def initialize(form: nil, report_part1_data: nil)
    @form = form
    @report_part1_data = report_part1_data
  end

  delegate :annual_report, to: :form, prefix: true
  delegate :fiscal_year_ending, to: :form_annual_report
  delegate :reserve, to: :form_annual_report, prefix: true
  delegate :managing_campus, to: :form_annual_report_reserve, prefix: true

  attr_reader :report_part1_data, :form

  def report_part1
    @report_part1 ||= report_part1_data
      .map { |row| Manager::Reports::ReportPart1RowPresenter.new(row) }
      .group_by { |row| row["project_type"] }
  end

  def row_total
    report_part1["TOTAL"]&.first
  end

  def report_part1_columns
    report_part1_data.columns.excluding("project_type", "role")
  end

  def fiscal_year
    "#{fiscal_year_ending - 1}-#{fiscal_year_ending}"
  end

  def fiscal_year_ending_options
    (Date.current.year + 1).downto(2000).map { |year_end| ["#{year_end - 1}-#{year_end}", year_end] }
  end

  def report_begin_date
    Date.new(fiscal_year_ending - 1, FISCAL_MONTH_BEGIN, FISCAL_DAY_BEGIN)
  end

  def report_end_date
    Date.new(fiscal_year_ending, FISCAL_MONTH_END, FISCAL_DAY_END)
  end

  def reserve_name
    form_annual_report_reserve.name
  end

  def reserve_managing_campus_name
    form_annual_report_reserve_managing_campus.name
  end

  def inst_type_translate(institution_type)
    case institution_type
    when "CountUCHome" || "DaysUCHome" then ""
    when "CountUCAway" || "DaysUCAway" then "university_of_california"
    when "CountCSU" || "DaysCSU" then "california_state_university_system"
    when "CountComCol" || "DaysComCol" then "california_community_college"
    when "CountOthCA" || "DaysOthCA" then "other_california_university_or_college"
    when "CountOthUS" || "DaysOthUS" then "non_california_us_university_or_college"
    when "CountIntl" || "DaysIntl" then "international_university_or_college"
    when "CountK12" || "DaysK12" then "k_12_education"
    when "CountNGO" || "DaysNGO" then "non_governmental_organization_or_entity"
    when "CountGov" || "DaysGov" then "governmental_organization_or_entity"
    when "CountBus" || "DaysBus" then "business_entity"
    when "CountOthers" || "DaysOther" then "individual_or_other_entity"
    else
      ""
    end
  end

  def role_translate(role)
    case role
    when "Faculty" then "faculty"
    when "Research Scientist/Post Doc" then "research_scientist"
    when "Research Assistant (non-student/faculty/postdoc)" then "research_assistant"
    when "Graduate Student" then "graduate_student"
    when "Undergraduate Student" then "undergraduate_student"
    when "K-12 Instructor" then "k_12_instructor"
    when "K-12 Student" then "k_12_student"
    when "Professional" then "professional"
    when "Other" then "other"
    when "Docent" then "docent"
    when "Volunteer" then "volunteer"
    else
      ""
    end
  end

  def institution_type_order_list
    @institution_type_order_list ||= report_part1_data.columns[2...-2].select!.with_index { |_, i| i.even? }
  end
end
