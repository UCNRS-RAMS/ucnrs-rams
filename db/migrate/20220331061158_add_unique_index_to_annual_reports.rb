class AddUniqueIndexToAnnualReports < ActiveRecord::Migration[6.1]
  def change
    reversible do |dir|
      dir.up do
        execute(<<-end_sql)
          DELETE table1
          FROM annual_reports table1
          INNER JOIN annual_reports table2
          WHERE table1.reserve_id = table2.reserve_id
            AND table1.fiscal_year_ending = table2.fiscal_year_ending
            AND (
              table1.created_at < table2.created_at
              OR (
                table1.created_at IS NULL
                AND table2.created_at IS NULL
                AND table1.id < table2.id
              )
              OR (
                table1.created_at = table2.created_at
                AND table1.id < table2.id
              )
            )
        end_sql
      end
    end
    add_index(
      :annual_reports,
      [:reserve_id, :fiscal_year_ending],
      unique: true,
      name: "unique_reserve_annual_reports"
    )
  end
end
