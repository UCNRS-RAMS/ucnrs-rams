require "csv"

CSV.generate do |csv|
  csv << [
    t("manager.reports.report_part_3_table.institution_type"),
    t("manager.reports.report_part_3_table.institution_name"),
    t("manager.reports.report_part_3_table.course"),
    t("manager.reports.report_part_3_content.course_number"),
    t("manager.reports.report_part_3_content.instructor"),
    t("manager.reports.report_part_3_content.date"),
    t("manager.reports.report_part_3_table.users"),
  ]

  @presenter.report_part3_data.each do |institution_type, institutions|
    institutions.each do |institution_name, projects|
      projects.each do |project|
        instructor = project.owner_name
        instructor += " - #{project.owner.department}" if project.owner.department.present?

        users = @presenter.project_user_details(project)
          .map { |role, count| "#{t("universal.roles.#{role}")}: #{count}" }
          .join("; ")

        csv << [
          institution_type,
          institution_name,
          project.course_title,
          project.course_number || project.abstract || "N/A",
          instructor,
          project.timeframe,
          users,
        ]
      end
    end
  end
end
