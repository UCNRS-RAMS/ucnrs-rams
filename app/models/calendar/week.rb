module Calendar
  class Week
    DAYS_PER_WEEK = 7

    attr_reader :dates

    def initialize(dates:, entries:)
      @dates = dates
      @entries = entries
    end

    def starts_on
      dates.first
    end

    def ends_on
      dates.last
    end

    def entries_starting_on(column)
      entries_this_week.select { |entry| leading_cells_for(entry) == column }
    end

    def entry_count
      entries_this_week.size
    end

    def leading_cells_for(entry)
      [ (entry.starts_on - starts_on).to_i, 0 ].max
    end

    def span_for(entry)
      ([ entry.ends_on, ends_on ].min - (starts_on + leading_cells_for(entry))).to_i + 1
    end

    def trailing_cells_for(entry)
      DAYS_PER_WEEK - leading_cells_for(entry) - span_for(entry)
    end

    def modifiers_for(entry)
      [
        ("prev-week" if entry.starts_on < starts_on),
        ("next-week" if entry.ends_on > ends_on)
      ].compact
    end

    private

    attr_reader :entries

    def entries_this_week
      @entries_this_week ||= entries.select { |entry|
        entry.ends_on >= starts_on && entry.starts_on <= ends_on
      }
    end
  end
end
