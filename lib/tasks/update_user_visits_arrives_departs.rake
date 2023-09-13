namespace :db do
  desc "Update user visits arrives and departs based on the ArrivalDate + ArrivalTime and
    DepartureDate + DepartureTime respectively."

  task update_user_visits_arrives_departs: :environment do
    UserVisit.where.not(ArrivalDate: nil)
      .where.not(ArrivalTime: nil)
      .where.not(DepartureDate: nil)
      .where.not(DepartureTime: nil)
      .find_each do |user_visit|

        arrives = user_visit.ArrivalDate.to_time.in_time_zone("Pacific Time (US & Canada)") +
          user_visit.ArrivalTime.in_time_zone("Pacific Time (US & Canada)").hour.hour
        departs = user_visit.DepartureDate.to_time.in_time_zone("Pacific Time (US & Canada)") +
          user_visit.DepartureTime.in_time_zone("Pacific Time (US & Canada)").hour.hour

        user_visit.update_columns(
          arrives_at: arrives,
          departs_at: departs
        )
      end
  end
end
