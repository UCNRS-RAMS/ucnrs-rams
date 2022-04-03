class UseConventionalNameForInvRecipients < ActiveRecord::Migration[6.1]
  def change
    rename_table :InvRecipients, :invoice_recipients

    rename_column :invoice_recipients, :InvRecipientID, :id
  end
end
