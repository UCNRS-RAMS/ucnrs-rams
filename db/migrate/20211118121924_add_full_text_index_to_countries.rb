class AddFullTextIndexToCountries < ActiveRecord::Migration[6.1]
  def up
    execute(<<~end_sql)
      ALTER TABLE countries
      ADD FULLTEXT INDEX country_search (name)
    end_sql
  end

  def down
    execute(<<~end_sql)
      ALTER TABLE countries
      DROP INDEX country_search
    end_sql
  end
end
