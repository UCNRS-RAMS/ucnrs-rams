class AddFullTextIndexToInstitutions < ActiveRecord::Migration[6.1]
  def up
    execute(<<~end_sql)
      ALTER TABLE institutions
      ADD FULLTEXT INDEX institution_search (name, city, acronym)
    end_sql
  end

  def down
    execute(<<~end_sql)
      ALTER TABLE institutions
      DROP INDEX institution_search
    end_sql
  end
end
