namespace :db do
  desc "Destroy Visits with missing reserve."
  task destroy_visits_with_missing_reserve: :environment do
    Visit.where(reserve_id: nil).find_each do |visit|
      visit.user_visits.destroy_all
      visit.amenity_visits.destroy_all
      visit.visit_reserve_answers.destroy_all
      visit.logs.destroy_all

      visit.invoices.find_each do |invoice|
        invoice.invoice_recipients.destroy_all
        invoice.invoice_payments.destroy_all
      end

      visit.invoices.destroy_all
      visit.destroy
    end
  end
end
