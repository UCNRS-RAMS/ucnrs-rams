namespace :db do
  desc "Destroy orphaned invoices."
  task destroy_orphaned_invoices: :environment do
    Invoice.left_joins(:visit).where(visit: { id: nil }).find_each do |invoice|
      invoice.amenity_visits.destroy_all
      invoice.invoice_recipients.destroy_all
      invoice.invoice_payments.destroy_all

      invoice.destroy
    end
  end
end
