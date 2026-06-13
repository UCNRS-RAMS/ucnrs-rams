require "csv"

CSV.generate do |csv|
  csv << [
    t("manager.reports.report_part_9_table.institution_type"),
    t("manager.reports.report_part_9_table.institution_name"),
    t("manager.reports.report_part_9_data.project_title"),
    t("manager.reports.report_part_9_table.abstract"),
    t("manager.reports.report_part_9_content.owner"),
    t("manager.reports.report_part_9_content.date"),
    t("manager.reports.report_part_9_table.users"),
  ]

  @presenter.report_part9_data.each do |institution_type, institutions|
    institutions.each do |institution_name, projects|
      projects.each do |project|
        owner = project.owner_name
        owner += " - #{project.owner.department}" if project.owner.department.present?

        users = @presenter.project_user_details(project)
          .map { |role, count| "#{t("universal.roles.#{role}")}: #{count}" }
          .join("; ")

        csv << [
          institution_type,
          institution_name,
          project.title,
          project.abstract || "N/A",
          owner,
          project.timeframe,
          users,
        ]
      end
    end
  end
end
