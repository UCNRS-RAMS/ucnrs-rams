class UseConventionalNameForDisciplines < ActiveRecord::Migration[6.1]
  def change
    rename_table :Disciplines, :disciplines_temp
    rename_table :disciplines_temp, :disciplines
    rename_column :disciplines, :DisciplineID, :id
    rename_column :disciplines, :DisciplineName, :name
    rename_column :disciplines, :DisciplineCategory, :category
  end
end
