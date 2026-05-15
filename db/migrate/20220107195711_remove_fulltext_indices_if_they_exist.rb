class RemoveFulltextIndicesIfTheyExist < ActiveRecord::Migration[6.1]
  def up
    begin
      execute("ALTER TABLE institutions DROP INDEX institution_search")
    rescue ActiveRecord::StatementInvalid => e
      Rails.logger.debug "institution_search index does not exist"
    end

    begin
      execute("ALTER TABLE countries DROP INDEX country_search")
    rescue ActiveRecord::StatementInvalid => e
      Rails.logger.debug "country_search index does not exist"
    end

    begin
      execute("ALTER TABLE users DROP INDEX user_search")
    rescue ActiveRecord::StatementInvalid => e
      Rails.logger.debug "user_search index does not exist"
    end
  end

  def down
    # Do nothing.
  end
end
