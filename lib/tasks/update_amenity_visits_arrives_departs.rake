namespace :db do
  desc "Update amenity visits arrives and departs based on the arrives_on + arrives_at and departs_on + departs_at respectively."

  task update_amenity_visits_arrives_departs: :environment do
    AmenityVisit.where.not(arrives_on: nil)
      .where.not(arrives_at: nil)
      .where.not(departs_on: nil)
      .where.not(departs_on: nil)
      .find_each do |amenity_visit|

        arrives = amenity_visit.arrives_on.to_time.in_time_zone("Pacific Time (US & Canada)") +
          amenity_visit.arrives_at.in_time_zone("Pacific Time (US & Canada)").hour.hour
        departs = amenity_visit.departs_on.to_time.in_time_zone("Pacific Time (US & Canada)") +
          amenity_visit.departs_at.in_time_zone("Pacific Time (US & Canada)").hour.hour

        # rubocop:disable Rails/SkipsModelValidations
        amenity_visit.update_columns(
          arrives: arrives,
          departs: departs
        )
        # rubocop:enable Rails/SkipsModelValidations
      end
  end
end
