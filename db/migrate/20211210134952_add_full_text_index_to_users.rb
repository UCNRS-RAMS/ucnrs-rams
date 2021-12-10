class AddFullTextIndexToUsers < ActiveRecord::Migration[6.1]
  def up
    execute(<<~end_sql)
      ALTER TABLE users
      ADD FULLTEXT INDEX name_search (first_name, middle_name, last_name) WITH PARSER ngram
    end_sql
  end

  def down
    execute(<<~end_sql)
      ALTER TABLE users
      DROP INDEX name_search
    end_sql
  end
end
