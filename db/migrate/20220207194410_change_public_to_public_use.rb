class ChangePublicToPublicUse < ActiveRecord::Migration[6.1]
  def change
    rename_column :reserve_questions, :public, :public_use
  end
end
