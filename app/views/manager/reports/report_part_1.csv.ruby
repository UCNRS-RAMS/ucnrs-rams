csv = CSV.new("")

csv << [
  nil,
  t("reports.part_1.uc_home"), nil,
  t("reports.part_1.uc_other"), nil,
  t("reports.part_1.csu_system"), nil,
  t("reports.part_1.ca_community_college"), nil,
  t("reports.part_1.ca_other_college"), nil,
  t("reports.part_1.out_of_state_college"), nil,
  t("reports.part_1.international_university"), nil,
  t("reports.part_1.k12_school"), nil,
  t("reports.part_1.ngo_non_profit"), nil,
  t("reports.part_1.government"), nil,
  t("reports.part_1.business_entity"), nil,
  t("reports.part_1.other"), nil,
  t("reports.part_1.total"), nil
]

header2 = [nil]
13.times { header2 << t("reports.part_1.users") << t("reports.part_1.user_days") }

csv << header2

@presenter.report_part1.except("TOTAL").each do |group, rows|
  subheader = [group]
  26.times { subheader << nil }

  csv << subheader

  rows.each do |row|
    body = [row.role]
    @presenter.report_part1_columns.each { |column| body << row[column] }

    csv << body
  end
end

if @presenter.row_total.present?
  total = [t("reports.part_1.total")]
  @presenter.report_part1_columns.each { |column| total << @presenter.row_total[column] }

  csv << total
end

csv.string
