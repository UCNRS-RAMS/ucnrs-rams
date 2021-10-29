class UseConventionalNameForWaivers < ActiveRecord::Migration[6.1]
  def change
    rename_table :Waivers, :old_waivers
    rename_column :old_waivers, :WaiverID, :id
    rename_column :old_waivers, :Name, :name
    rename_column :old_waivers, :Description, :description
    rename_column :old_waivers, :WaiverURL, :url
    rename_column :old_waivers, :SortOrder, :sort_order
    rename_column :old_waivers, :Online, :online
    rename_column :old_waivers, :OnlineHTMLText, :online_html_text
    rename_column :old_waivers, :NumberOfYearsUntilExpire, :years_until_expire

    change_column_comment :old_waivers, :reserve_id_temp, to: "DEPRECATED", from: nil

    rename_index :old_waivers, :SortOrderPlain, :sort_order
    rename_index :old_waivers, :ReserveIDPlain, :reserve_id
    rename_index :old_waivers, :ReserveAndSortOrder, :reserve_and_sort_order

    reversible do |dir|
      dir.up do
        execute("UPDATE old_waivers SET online = 1 WHERE online > 0")
        execute("UPDATE old_waivers SET online = 0 WHERE online IS NULL")
      end
    end

    reversible do |dir|
      dir.up { change_column :old_waivers, :online, :boolean }
      dir.down { change_column :old_waivers, :online, :integer }
    end

    change_column_null :old_waivers, :online, false
  end
end
