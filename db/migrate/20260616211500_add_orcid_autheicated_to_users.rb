class AddOrcidAutheicatedToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :orcid_authenticated, :boolean, default: false, null: false, after: :orcid
  end
end
