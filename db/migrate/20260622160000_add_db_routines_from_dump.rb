class AddDbRoutinesFromDump < ActiveRecord::Migration[8.1]
  def up
    DbRoutinesLoader.load_missing(connection: connection)
  end

  def down
    # intentionally empty:
    # we cannot safely determine which routines predated this migration, but on newly migrated databases there were
    # none before this unless they were added manually.
  end

end

