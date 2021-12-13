class MoveReserveIdToVisits < ActiveRecord::Migration[6.1]
  def up
    execute("UPDATE visits LEFT OUTER JOIN projects ON visits.project_id = projects.id SET visits.reserve_id = projects.reserve_id")
  end
end
