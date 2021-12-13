class AddColumnStartsAtEndsAtToVisit < ActiveRecord::Migration[6.1]
  def change
    add_column :visits, :starts_at, :datetime
    add_column :visits, :ends_at, :datetime
  end
end
