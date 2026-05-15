class AddFullTextIndexToUsers < ActiveRecord::Migration[6.1]
  def up
    # execute(<<~end_sql)
    #   ALTER TABLE users
    #   ADD FULLTEXT INDEX name_search (first_name, middle_name, last_name) WITH PARSER ngram
    # end_sql
  end

  def down
    begin
      execute("ALTER TABLE users DROP INDEX user_search")
    rescue ActiveRecord::StatementInvalid => e
      Rails.logger.debug "user_search index does not exist"
    end
  end
end
