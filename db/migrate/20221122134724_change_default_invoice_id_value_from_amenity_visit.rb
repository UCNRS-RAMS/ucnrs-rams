class ChangeDefaultInvoiceIdValueFromAmenityVisit < ActiveRecord::Migration[6.1]
  def change
    change_column_default :amenity_visits, :invoice_id, from: 0, to: nil
  end
end
