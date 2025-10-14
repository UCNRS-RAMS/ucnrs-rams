# frozen_string_literal: true

class Manager::Reports::Flex::ReportPart1Presenter
  def initialize(report_part1_data: nil, date_begin: nil, date_end: nil)
    @report_part1_data = report_part1_data
    @date_begin = date_begin
    @date_end = date_end
  end

  attr_reader :report_part1_data, :date_begin, :date_end

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

  def report_begin_date
    date_begin
  end

  def report_end_date
    date_end
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
