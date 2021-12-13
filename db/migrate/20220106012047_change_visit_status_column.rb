class ChangeVisitStatusColumn < ActiveRecord::Migration[6.1]
  def up
    execute("ALTER TABLE visits MODIFY COLUMN status ENUM('Approved','Pending approval','Cancelled','Temp','approved_temp','in_review','cancelled_temp','incomplete')")
    execute("UPDATE visits SET status = 'approved_temp' WHERE status = 'Approved'")
    execute("UPDATE visits SET status = 'in_review' WHERE status = 'Pending approval'")
    execute("UPDATE visits SET status = 'cancelled_temp' WHERE status = 'Cancelled'")
    execute("UPDATE visits SET status = 'incomplete' WHERE status = 'Temp'")
    execute("ALTER TABLE visits MODIFY COLUMN status ENUM('approved','in_review','cancelled','incomplete','approved_temp','cancelled_temp')")
    execute("UPDATE visits SET status = 'approved' WHERE status = 'approved_temp'")
    execute("UPDATE visits SET status = 'cancelled' WHERE status = 'cancelled_temp'")
    execute("ALTER TABLE visits MODIFY COLUMN status ENUM('approved','in_review','cancelled','incomplete')")
    execute("ALTER TABLE visits ALTER status SET DEFAULT 'incomplete'")
  end

  def down
    execute("ALTER TABLE visits MODIFY COLUMN status ENUM('approved','in_review','cancelled','incomplete','Approved_temp','Pending approval','Cancelled_temp','Temp')")
    execute("UPDATE visits SET status = 'Approved_temp' WHERE status = 'approved'")
    execute("UPDATE visits SET status = 'Pending approval' WHERE status = 'in_review'")
    execute("UPDATE visits SET status = 'Cancelled_temp' WHERE status = 'cancelled'")
    execute("UPDATE visits SET status = 'Temp' WHERE status = 'incomplete'")
    execute("ALTER TABLE visits MODIFY COLUMN status ENUM('Approved','Pending approval','Cancelled','Temp','Approved_temp','Cancelled_temp')")
    execute("UPDATE visits SET status = 'Approved' WHERE status = 'Approved_temp'")
    execute("UPDATE visits SET status = 'Cancelled' WHERE status = 'Cancelled_temp'")
    execute("ALTER TABLE visits MODIFY COLUMN status ENUM('Approved','Pending approval','Cancelled','Temp')")
    execute("ALTER TABLE visits ALTER status SET DEFAULT 'Temp'")
  end
end
