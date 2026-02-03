class ChangeDatabaseToMatchLiveProduction < ActiveRecord::Migration[7.0]
  def change
    rename_index :visits, :ActivityID, :id
  end
end
