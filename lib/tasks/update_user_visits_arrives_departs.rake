namespace :db do
  desc "Update user visits arrives and departs based on the ArrivalDate + ArrivalTime and
    DepartureDate + DepartureTime respectively."

  task update_user_visits_arrives_departs: :environment do
    UserVisit.where.not(ArrivalDate: nil)
      .where.not(ArrivalTime: nil)
      .where.not(DepartureDate: nil)
      .where.not(DepartureTime: nil)
      .find_each do |user_visit|

        arrives = user_visit.ArrivalDate.to_time.localtime + user_visit.ArrivalTime.localtime.hour.hour
        departs = user_visit.DepartureDate.to_time.localtime + user_visit.DepartureTime.localtime.hour.hour

        user_visit.update_columns(
          arrives_at: arrives,
          departs_at: departs
        )
      end
  end
end
