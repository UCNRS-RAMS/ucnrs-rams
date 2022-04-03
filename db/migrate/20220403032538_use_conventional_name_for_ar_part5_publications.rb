class UseConventionalNameForArPart5Publications < ActiveRecord::Migration[6.1]
  def change
    rename_table :ARPart5Publications, :publications

    change_table_comment :publications, from: nil, to: "Obsolete table."
  end
end
