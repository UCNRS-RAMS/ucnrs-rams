class ChangeInvoiceidNull < ActiveRecord::Migration[6.1]
  def change
    change_column_null :invoice_payments, :invoice_id, true
  end
end
