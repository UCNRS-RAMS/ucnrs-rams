class UpdateReservePersonnelRoleEnum < ActiveRecord::Migration[6.1]
  def change
    reversible do |dir|
      dir.up do
        ReservePersonnel.update_all(role: nil)
        execute <<~SQL
          ALTER TABLE reserve_personnel MODIFY COLUMN `role` ENUM('Administrator','View Only','Accountant') DEFAULT 'Administrator';
        SQL
        ReservePersonnel.update_all(role: 'Administrator')
      end
      dir.down do
        execute <<~SQL
          ALTER TABLE reserve_personnel MODIFY COLUMN `role` ENUM('No selection made','Reserve manager','Reserve assistant manager','Reserve co-manager','Reserve steward','Reserve staff','Campus NRS director','Campus committee member','Information manager','Faculty reserve manager','Reserve accountant','Resident researcher') DEFAULT 'No selection made';
        SQL
      end
    end
  end
end
