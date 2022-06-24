class ChangeLogsToLogsOld < ActiveRecord::Migration[6.1]
  def change
    rename_table :logs, "logs-old"
    rename_table :logx, :logs
  end
end
