class DateQuery
  module Scopes
    def having_date_after(scope, date_type, date_var)
      return self unless date_type.present? && date_var.present?

      where(scope.arel_table[date_type].gteq(date_var))
    end
  
    def having_date_before(scope, date_type, date_var)
      return self unless date_type.present? && date_var.present?

      where(scope.arel_table[date_type].lteq(date_var))
    end
  end

  def self.call(scope, filters)
    new(scope).call(filters)
  end

  def initialize(scope)
    @scope = scope
  end

  def call(filters = {})
    @scope
      .extending(Scopes)
      .having_date_after(@scope, filters[:date_start_type], filters[:date_start])
      .having_date_before(@scope, filters[:date_end_type], filters[:date_end])
  end
end
