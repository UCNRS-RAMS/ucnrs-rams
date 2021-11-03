class ChangeProjectTypeEnumOnProject < ActiveRecord::Migration[6.1]
  def up
    execute("ALTER TABLE projects MODIFY COLUMN project_type ENUM('Research','Class','Public','Public Use','Housing','Meeting','All')")
    execute("UPDATE projects SET project_type = 'Public Use' WHERE project_type = 'Public'")
    execute("ALTER TABLE projects MODIFY COLUMN project_type ENUM('Research','Class','Public Use','Housing','Meeting')")
  end

  def down
    execute("ALTER TABLE projects MODIFY COLUMN project_type ENUM('Research','Class','Public','Public Use','Housing','Meeting','All')")
    execute("UPDATE projects SET project_type = 'Public' WHERE project_type = 'Public Use'")
    execute("ALTER TABLE projects MODIFY COLUMN project_type ENUM('Research','Class','Public','Housing','Meeting','All')")
  end
end
