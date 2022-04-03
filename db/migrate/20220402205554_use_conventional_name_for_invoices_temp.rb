class UseConventionalNameForInvoicesTemp < ActiveRecord::Migration[6.1]
  def change
    rename_table :InvoicesTemp, :invoices_temporary

    rename_column :invoices_temporary, :InvoiceTempID, :id
    rename_column :invoices_temporary, :InvoiceNow, :invoice_now
    rename_column :invoices_temporary, :BalanceDue, :balance_due

    change_table_comment :invoices_temporary, from: nil, to: "Obsolete table."
  end
end
