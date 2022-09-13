class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  NUMERIC_SEARCH_PATTERN = /\A\d+\z/
end
