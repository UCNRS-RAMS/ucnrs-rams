class AddNewFeatureTable < ActiveRecord::Migration[6.1]
  def change
    create_table :new_features do |t|
      t.string :title, null: false
      t.timestamps
    end
  end
end
