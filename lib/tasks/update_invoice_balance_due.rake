namespace :db do
  desc "Update the balance_due column for all invoices"
  task update_invoice_balance_due: :environment do
    Invoice.find_each do |invoice|
      invoice.update_balance_due
    end
  end
end
