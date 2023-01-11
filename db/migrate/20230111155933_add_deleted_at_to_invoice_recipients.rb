class AddDeletedAtToInvoiceRecipients < ActiveRecord::Migration[6.1]
  def change
    add_column :invoice_recipients, :deleted_at, :datetime
    add_index :invoice_recipients, :deleted_at
  end
end
