require "csv"

CSV.generate do |csv|
  csv << [
    t("manager.reports.report_part_4_data.project_title"),
    t("manager.reports.report_part_4_data.project_dates"),
    t("manager.reports.report_part_4_data.principal_investigators"),
    t("manager.reports.report_part_4_data.other_members"),
    t("manager.reports.report_part_4_data.affiliations"),
    t("manager.reports.report_part_4_data.project_abstract"),
  ]

  @presenter.report_part4_data.each do |project|
    principal_investigators = project.principal_investigators
      .map(&:full_name)
      .join(" | ")

    other_members =
      if project.other_team_members.present?
        project.other_team_members.map(&:full_name).join(" | ")
      else
        t("manager.reports.report_part_4_data.none")
      end

    csv << [
      project.title,
      project.timeframe,
      principal_investigators,
      other_members,
      project.team_members_affiliations.join(" | "),
      project.abstract,
    ]
  end
end
