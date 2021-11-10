class AddStudyAreaToVisits < ActiveRecord::Migration[6.1]
  def change
    add_column :visits, :study_area, :string
  end
end
