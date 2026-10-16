require "rails_helper"

RSpec.describe Calendar::Week do
  def week_of_may_3(entries)
    dates = Date.new(2026, 5, 3).upto(Date.new(2026, 5, 9)).to_a
    Calendar::Week.new(dates: dates, entries: entries)
  end

  def entry(id:, starts_on:, ends_on:)
    Calendar::Entry.new(
      id: id, kind: :user, status: :approved, title: "t",
      visit_id: 1, starts_on: starts_on, ends_on: ends_on,
    )
  end

  describe "positioning a bar" do
    it "places an entry that sits entirely inside the week" do
      e = entry(id: 1, starts_on: Date.new(2026, 5, 5), ends_on: Date.new(2026, 5, 7))
      week = week_of_may_3([ e ])

      expect(week.leading_cells_for(e)).to eq 2
      expect(week.span_for(e)).to eq 3
      expect(week.trailing_cells_for(e)).to eq 2
      expect(week.modifiers_for(e)).to eq []
    end

    it "clips an entry that runs past the end of the week" do
      e = entry(id: 1, starts_on: Date.new(2026, 5, 7), ends_on: Date.new(2026, 5, 20))
      week = week_of_may_3([ e ])

      expect(week.leading_cells_for(e)).to eq 4
      expect(week.span_for(e)).to eq 3
      expect(week.trailing_cells_for(e)).to eq 0
      expect(week.modifiers_for(e)).to eq [ "next-week" ]
    end

    it "clips an entry that started in an earlier week" do
      e = entry(id: 1, starts_on: Date.new(2026, 4, 20), ends_on: Date.new(2026, 5, 5))
      week = week_of_may_3([ e ])

      expect(week.leading_cells_for(e)).to eq 0
      expect(week.span_for(e)).to eq 3
      expect(week.modifiers_for(e)).to eq [ "prev-week" ]
    end

    it "marks both edges for an entry spanning the whole week" do
      e = entry(id: 1, starts_on: Date.new(2026, 4, 1), ends_on: Date.new(2026, 6, 1))
      week = week_of_may_3([ e ])

      expect(week.leading_cells_for(e)).to eq 0
      expect(week.span_for(e)).to eq 7
      expect(week.trailing_cells_for(e)).to eq 0
      expect(week.modifiers_for(e)).to eq [ "prev-week", "next-week" ]
    end

    it "always totals seven cells, wherever the bar sits" do
      entries = [
        entry(id: 1, starts_on: Date.new(2026, 5, 3), ends_on: Date.new(2026, 5, 3)),
        entry(id: 2, starts_on: Date.new(2026, 5, 6), ends_on: Date.new(2026, 5, 6)),
        entry(id: 3, starts_on: Date.new(2026, 5, 9), ends_on: Date.new(2026, 5, 9)),
        entry(id: 4, starts_on: Date.new(2026, 4, 1), ends_on: Date.new(2026, 6, 1)),
        entry(id: 5, starts_on: Date.new(2026, 5, 8), ends_on: Date.new(2026, 5, 25))
      ]
      week = week_of_may_3(entries)

      totals = entries.map { |e|
        week.leading_cells_for(e) + week.span_for(e) + week.trailing_cells_for(e)
      }

      expect(totals).to eq [ 7, 7, 7, 7, 7 ]
    end
  end

  describe "#entries_starting_on" do
    it "returns only bars whose leading cell count equals that column" do
      sunday = entry(id: 1, starts_on: Date.new(2026, 5, 3), ends_on: Date.new(2026, 5, 4))
      wednesday = entry(id: 2, starts_on: Date.new(2026, 5, 6), ends_on: Date.new(2026, 5, 6))
      week = week_of_may_3([ sunday, wednesday ])

      expect(week.entries_starting_on(0).map(&:id)).to eq [ 1 ]
      expect(week.entries_starting_on(3).map(&:id)).to eq [ 2 ]
      expect(week.entries_starting_on(5)).to eq []
    end

    it "agrees with leading_cells_for for every column" do
      entries = (3..9).map { |day|
        entry(id: day, starts_on: Date.new(2026, 5, day), ends_on: Date.new(2026, 5, day))
      }
      week = week_of_may_3(entries)

      (0..6).each do |column|
        week.entries_starting_on(column).each do |e|
          expect(week.leading_cells_for(e)).to eq column
        end
      end
    end

    it "omits entries that do not touch the week" do
      before_week = entry(id: 1, starts_on: Date.new(2026, 4, 1), ends_on: Date.new(2026, 5, 2))
      after_week  = entry(id: 2, starts_on: Date.new(2026, 5, 10), ends_on: Date.new(2026, 5, 12))
      week = week_of_may_3([ before_week, after_week ])

      expect((0..6).flat_map { |c| week.entries_starting_on(c) }).to eq []
      expect(week.entry_count).to eq 0
    end

    it "keeps the order the entries arrived in within a column" do
      first = entry(id: 1, starts_on: Date.new(2026, 5, 4), ends_on: Date.new(2026, 5, 4))
      second = entry(id: 2, starts_on: Date.new(2026, 5, 4), ends_on: Date.new(2026, 5, 4))
      week = week_of_may_3([ first, second ])

      expect(week.entries_starting_on(1).map(&:id)).to eq [ 1, 2 ]
    end

    it "spreads every overlapping entry across exactly one column" do
      entries = [
        entry(id: 1, starts_on: Date.new(2026, 5, 3), ends_on: Date.new(2026, 5, 4)),
        entry(id: 2, starts_on: Date.new(2026, 5, 6), ends_on: Date.new(2026, 5, 9)),
        entry(id: 3, starts_on: Date.new(2026, 5, 9), ends_on: Date.new(2026, 5, 30))
      ]
      week = week_of_may_3(entries)

      by_column = (0..6).flat_map { |column| week.entries_starting_on(column) }

      expect(by_column.map(&:id)).to eq [ 1, 2, 3 ]
      expect(by_column.size).to eq week.entry_count
    end
  end

  describe "immutability" do
    it "never mutates the entries it positions" do
      e = entry(id: 1, starts_on: Date.new(2026, 5, 5), ends_on: Date.new(2026, 5, 7))
      entries = [ e ]
      week = week_of_may_3(entries)

      2.times { (0..6).each { |c| week.entries_starting_on(c) } }

      expect(entries.size).to eq 1
      expect(entries.first.starts_on).to eq Date.new(2026, 5, 5)
    end
  end
end
