class PopulateProjectPermitAnswersTable < ActiveRecord::Migration[6.1]
  def up
    execute("UPDATE application_permit_answers SET answer = 0 WHERE answer IS NULL;")

    execute(<<~end_sql)
      DELETE application_permit_answers
      FROM
        application_permit_answers
        LEFT JOIN projects ON application_permit_answers.project_id = projects.id 
      WHERE
        projects.id IS NULL;
    end_sql

    execute(<<~end_sql)
      INSERT INTO project_permit_answers ( id, permit_id, project_id, answer, created_at, updated_at )
        SELECT
          application_permit_answers.id,
          reserve_permits.permit_id,
          application_permit_answers.project_id,
          application_permit_answers.answer,
          "1900-01-01",
          "1900-01-01"
        FROM
          application_permit_answers
          INNER JOIN reserve_permits ON application_permit_answers.reserve_permit_id = reserve_permits.id;
    end_sql
  end

  def down
    execute("DELETE FROM project_permit_answers")
  end
end
