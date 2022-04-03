class UseConventionalNameForInvoices < ActiveRecord::Migration[6.1]
  def change
    rename_column :invoices, :InvoiceID, :id
    rename_column :invoices, :InvoiceDate, :invoiced_on
    rename_column :invoices, :Notes, :notes
    rename_column :invoices, :Modified, :modify_number
    rename_column :invoices, :RAMS1BilledAmount, :rams1_billed_amount
    rename_column :invoices, :BalanceDue, :balance_due

    remove_column :invoices, :CommentReVoiding, :string
    remove_column :invoices, :Voided, :boolean
    remove_column :invoices, :complete, :boolean
    remove_column :invoices, :PaymentStatus, :boolean
    remove_column :invoices, :InvoiceSentNotes, :text
    remove_column :invoices, :r2ReserveIDTemp, :integer

    rename_column :InvoicesTemp, :InvoiceID, :invoice_id
    rename_column :InvoicesEdit, :InvoiceID, :invoice_id
    rename_column :InvPayments, :InvoiceID, :invoice_id
    rename_column :InvRecipients, :InvoiceID, :invoice_id

    rename_index :InvPayments, :InvoiceID, :invoice_id
    rename_index :InvRecipients, :Invoice, :invoice
  end
end
