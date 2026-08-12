class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  NUMERIC_SEARCH_PATTERN = /\A\d+\z/

  # Returns a safe SQL fragment for a case-insensitive LIKE against a JSON column.
  # The table and attribute names are quoted; the value should be supplied as a
  # bind parameter.
  def self.safe_json_lower_where_clause(table:, attribute:)
    "LOWER(#{connection.quote_table_name(table)}.#{connection.quote_column_name(attribute)}) LIKE ?"
  end
end
