class RemoveNullContraintFromReserveIdInProjects < ActiveRecord::Migration[6.1]
  def change
    change_column_null :projects, :reserve_id, true
  end
end
