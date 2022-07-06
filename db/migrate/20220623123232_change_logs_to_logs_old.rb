class ChangeLogsToLogsOld < ActiveRecord::Migration[6.1]
  def change
    rename_table :logs, "logs-old"
    rename_table :logx, :logs

    change_table_comment "logs-old", from: nil, to: "DEPRECATED"
  end
end
