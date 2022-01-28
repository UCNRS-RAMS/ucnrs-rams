class AddUniqueIndexToProjectPermitAnswers < ActiveRecord::Migration[6.1]
  def change
    reversible do |dir|
      dir.up do
        execute(<<-end_sql)
          DELETE ppa1 
          FROM project_permit_answers ppa1 
          INNER join project_permit_answers ppa2
          WHERE ppa1.project_id = ppa2.project_id
            AND ppa1.permit_id = ppa2.permit_id
            AND (
              ppa1.created_at < ppa2.created_at
              OR (
                ppa1.created_at = ppa2.created_at
                AND ppa1.id < ppa2.id
              )
            )
        end_sql
      end
    end
    add_index :project_permit_answers, [:project_id, :permit_id], unique: true
  end
end
