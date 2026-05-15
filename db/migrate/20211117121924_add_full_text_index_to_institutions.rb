class AddFullTextIndexToInstitutions < ActiveRecord::Migration[6.1]
  def up
    # execute(<<~end_sql)
    #   ALTER TABLE institutions
    #   ADD FULLTEXT INDEX institution_search (name, city, acronym)
    # end_sql
  end

  def down
    begin
      execute("ALTER TABLE institutions DROP INDEX institution_search")
    rescue ActiveRecord::StatementInvalid => e
      Rails.logger.debug "institution_search index does not exist"
    end
  end
end
