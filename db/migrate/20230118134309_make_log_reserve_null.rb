class MakeLogReserveNull < ActiveRecord::Migration[6.1]
  def change
    change_column_null :logs, :reserve_id, true
  end
end
