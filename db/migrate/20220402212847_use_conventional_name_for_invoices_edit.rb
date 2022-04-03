class UseConventionalNameForInvoicesEdit < ActiveRecord::Migration[6.1]
  def change
    rename_table :InvoicesEdit, :invoices_edit

    rename_column :invoices_edit, :InvoicesEditID, :id
    rename_column :invoices_edit, :EditNumber, :edit_number
    rename_column :invoices_edit, :EditDate, :edited_on
    rename_column :invoices_edit, :EditReason, :reason

    change_table_comment :invoices_edit, from: nil, to: "Obsolete table."
  end
end
