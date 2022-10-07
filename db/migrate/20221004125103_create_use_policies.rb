class CreateUsePolicies < ActiveRecord::Migration[6.1]
  def change
    create_table :use_policies do |t|
      t.text :title
      t.text :description
      t.text :policy_link_text
      t.column :agreement_type, "ENUM('Reserve Use Agreement','Code of Conduct Agreement','Data Management Agreement')"
      t.text :image_url
      t.integer :sort_order

      t.timestamps
    end
  end
end
