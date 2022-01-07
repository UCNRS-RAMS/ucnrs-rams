class AddFullTextIndexToCountries < ActiveRecord::Migration[6.1]
  def up
    # execute(<<~end_sql)
    #   ALTER TABLE countries
    #   ADD FULLTEXT INDEX country_search (name)
    # end_sql
  end

  def down
    begin
      execute("ALTER TABLE countries DROP INDEX country_search")
    rescue ActiveRecord::StatementInvalid => e
      puts "country_search index does not exist"
    end
  end
end
