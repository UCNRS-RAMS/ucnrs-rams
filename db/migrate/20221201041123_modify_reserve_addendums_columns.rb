class ModifyReserveAddendumsColumns < ActiveRecord::Migration[6.1]
  def change
    remove_column :reserve_addendums, :info_text, :text
    remove_column :reserve_addendums, :url_link, :string, limit: 255
    remove_column :reserve_addendums, :url_text, :string, limit: 255
    remove_column :reserve_addendums, :info_format, "enum('text','html','embed_code','image')", default: 'text', null: false

    rename_column :reserve_addendums, :subject, :name
  end
end
