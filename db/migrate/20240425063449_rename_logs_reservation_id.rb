class RenameLogsReservationId < ActiveRecord::Migration[6.1]
  def change
    rename_column :logs, :reservation_id, :visit_id
  end
end
