class UseConventionalNameForInvPayments < ActiveRecord::Migration[6.1]
  def change
    rename_table :InvPayments, :invoice_payments

    rename_column :invoice_payments, :PaymentID, :id
    rename_column :invoice_payments, :Amount, :amount
    rename_column :invoice_payments, :Date, :paid_on
    rename_column :invoice_payments, :Notes, :notes
    rename_column :invoice_payments, :PayorName, :payor
    rename_column :invoice_payments, :PaymentType, :payment_type

    remove_column :invoice_payments, :visit_id, :integer
  end
end
