class ChangeClassToUniversityClass < ActiveRecord::Migration[6.1]
  def change
    rename_column :reserve_questions, :class, :university_class
  end
end
