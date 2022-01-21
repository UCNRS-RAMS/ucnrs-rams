class AddAndAssignUnknownInstitution < ActiveRecord::Migration[6.1]
  def up
    execute("INSERT INTO institutions (name) VALUES ('Unknown')")
    execute("UPDATE users SET institution_id=(SELECT id FROM institutions WHERE name='Unknown') WHERE institution_id is NULL")
  end

  def down
    execute("UPDATE users SET institution_id=NULL WHERE institution_id=(SELECT id FROM institutions WHERE name='Unknown')")
    execute("DELETE FROM institutions WHERE name='Unknown'")
  end
end
