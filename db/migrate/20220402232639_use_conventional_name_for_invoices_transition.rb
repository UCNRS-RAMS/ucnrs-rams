class UseConventionalNameForInvoicesTransition < ActiveRecord::Migration[6.1]
  def change
    rename_table :InvoicesTransition, :invoices_transition

    rename_column :invoices_transition, :InvoiceID, :id
    rename_column :invoices_transition, :Notes, :notes
    rename_column :invoices_transition, :Modified, :modified
    rename_column :invoices_transition, :Voided, :voided
    rename_column :invoices_transition, :CommentReVoiding, :voided_comment
    rename_column :invoices_transition, :r2ReserveIDTemp, :r2_reserve_id_temp
    rename_column :invoices_transition, :RAMS1BilledAmount, :rams1_billed_amount

    change_table_comment :invoices_transition, from: nil, to: "Obsolete table."
  end
end
