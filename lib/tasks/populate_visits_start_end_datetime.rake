namespace :db do
  desc "Populate visits table start and end datetime columns (please run 'rake db:update_user_visits_arrives_departs' first)"
  task populate_visits_start_end: :environment do
    Visit.find_each do |visit|
      next unless visit.user_visits.exists?

      visit_starts_at = visit.user_visits.min_by(&:arrives_at).arrives_at
      visit_ends_at = visit.user_visits.max_by(&:departs_at).departs_at

      visit.update_columns(
        starts_at: visit_starts_at, start_date: visit_starts_at.to_date, start_time: visit_starts_at,
        ends_at: visit_ends_at, end_date: visit_ends_at.to_date, end_time: visit_ends_at
      )
    end
  end
end
