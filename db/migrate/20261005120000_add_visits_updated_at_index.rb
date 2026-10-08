class AddVisitsUpdatedAtIndex < ActiveRecord::Migration[8.1]
  def change
    # Serves the updated_since filter: a platform-wide client reads visits by
    # updated_at directly, and a reserve-scoped client scans only its reserve's
    # rows through the existing reserve_id index.
    add_index :visits, :updated_at
  end
end
