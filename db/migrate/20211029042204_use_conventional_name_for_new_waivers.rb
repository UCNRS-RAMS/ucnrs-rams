class UseConventionalNameForNewWaivers < ActiveRecord::Migration[6.1]
  def change
    rename_table :new_waivers, :waivers

    rename_column :waivers, :url1, :url

    change_column_null :waivers, :name, false

    add_column :waivers, :url_type, "enum('link','pdf')", default: 'link', null: false
  end
end
