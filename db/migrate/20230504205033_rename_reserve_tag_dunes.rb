class RenameReserveTagDunes < ActiveRecord::Migration[6.1]
  def up
    execute("UPDATE reserve_tags SET reserve_tags.name = 'Dune' WHERE reserve_tags.name = 'Dunes'")
  end
end
