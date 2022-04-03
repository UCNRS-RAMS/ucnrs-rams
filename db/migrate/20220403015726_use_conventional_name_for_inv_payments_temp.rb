class UseConventionalNameForInvPaymentsTemp < ActiveRecord::Migration[6.1]
  def change
    rename_table :InvPaymentsTemp, :invoice_payments_temporary

    rename_column :invoice_payments_temporary, :InvPaymentsTempID, :id
    rename_column :invoice_payments_temporary, :Amount, :amount
    rename_column :invoice_payments_temporary, :Date, :paid_on
    rename_column :invoice_payments_temporary, :Notes, :notes
    rename_column :invoice_payments_temporary, :PayorName, :payor
    rename_column :invoice_payments_temporary, :PaymentType, :payment_type
  end
end
