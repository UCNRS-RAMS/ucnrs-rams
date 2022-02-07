class AddDeniedToVisitStatus < ActiveRecord::Migration[6.1]
  def up
    execute("ALTER TABLE visits MODIFY COLUMN status ENUM('approved','in_review','cancelled','incomplete','denied')")
    execute("ALTER TABLE visits ALTER status SET DEFAULT 'incomplete'")
  end
end
