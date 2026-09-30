# frozen_string_literal: true

# The legacy MySQL schema that the first migration copied in gives +projects+ and
# +visits+ an +updated_at+ that is NOT NULL and defaults to "0001-01-01".
#
# A column default populates the attribute as soon as a record is initialized,
# and ActiveRecord only writes the current time to a timestamp attribute that is
# still blank (ActiveRecord::Timestamp#_create_record), so every new project and
# visit was stored with the sentinel date rather than its creation time. It
# looked correct only after the row was updated for some other reason, and the
# sentinel leaked out through the manager UI and the JSON API.
#
# Dropping the default restores the usual behaviour, and rows still holding the
# sentinel are backfilled from their creation time.
class FixUpdatedAtDefaultOnProjectsAndVisits < ActiveRecord::Migration[8.1]
  # The value the legacy schema used in place of an absent timestamp.
  SENTINEL = "0001-01-01 00:00:00"

  TABLES = %i[projects visits].freeze

  def up
    TABLES.each do |table|
      # Nullable first: MySQL drops a column's default when it is redefined, so
      # the nullability has to be settled before the default is removed.
      change_column_null table, :updated_at, true
      change_column_default table, :updated_at, from: SENTINEL, to: nil

      execute(<<~SQL.squish)
        UPDATE #{table}
        SET updated_at = created_at
        WHERE updated_at = '#{SENTINEL}' AND created_at IS NOT NULL
      SQL
    end
  end

  def down
    TABLES.each do |table|
      change_column_default table, :updated_at, from: nil, to: SENTINEL
      change_column_null table, :updated_at, false
    end
  end
end
