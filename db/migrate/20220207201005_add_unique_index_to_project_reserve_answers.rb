class AddUniqueIndexToProjectReserveAnswers < ActiveRecord::Migration[6.1]
  def change
    reversible do |dir|
      dir.up do
        execute(<<-end_sql)
          DELETE table1
          FROM project_reserve_answers table1
          INNER JOIN project_reserve_answers table2
          WHERE table1.project_id = table2.project_id
            AND table1.reserve_question_id = table2.reserve_question_id
            AND (
              table1.created_at < table2.created_at
              OR table1.created_at IS NULL
              OR (
                table1.created_at = table2.created_at
                AND table1.id < table2.id
              )
            )
        end_sql
      end
    end
    add_index(
      :project_reserve_answers,
      [:project_id, :reserve_question_id],
      unique: true,
      name: "unique_project_reserve_answers"
    )
  end
end
