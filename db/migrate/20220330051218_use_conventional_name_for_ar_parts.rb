class UseConventionalNameForArParts < ActiveRecord::Migration[6.1]
  def change
    rename_table :ARParts, :annual_reports
    rename_column :annual_reports, :AnnualReportID, :id
    rename_column :annual_reports, :Year, :fiscal_year_ending
    rename_column :annual_reports, :YearOld, :year_old
    rename_column :annual_reports, :Part5Publications, :part_5_publications
    rename_column :annual_reports, :Part6Narrative, :part_6_narrative
    rename_column :annual_reports, :Part6NarrativeFile, :part_6_narrative_file
    rename_column :annual_reports, :Part7CampusCommittee, :part_7_campus_committee
    rename_column :annual_reports, :ApprovedPart1, :part_1_approved
    rename_column :annual_reports, :ApprovedPart2, :part_2_approved
    rename_column :annual_reports, :ApprovedPart3, :part_3_approved
    rename_column :annual_reports, :ApprovedPart4, :part_4_approved
    rename_column :annual_reports, :ApprovedPart5, :part_5_approved
    rename_column :annual_reports, :ApprovedPart6, :part_6_approved
    rename_column :annual_reports, :ApprovedPart7, :part_7_approved

    change_column_null :annual_reports, :fiscal_year_ending, false

    change_table_comment :annual_reports, from: nil, to: "renamed from ARParts."

    change_column_comment :annual_reports, :year_old, from: nil, to: "DEPRECATED"
  end
end
