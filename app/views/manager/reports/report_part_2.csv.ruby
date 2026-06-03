require "csv"

CSV.generate do |csv|
  csv << [
    t("manager.reports.report_part_2_table.institution_name"),
    t("manager.reports.report_part_2_table.location"),
  ]

  @presenter.report_part2_data.each do |institution_type, institutions|
    csv << [t("universal.institution_types.#{institution_type}")]

    institutions.each do |institution|
      csv << [institution.name, institution.address_line_3]
    end
  end
end
