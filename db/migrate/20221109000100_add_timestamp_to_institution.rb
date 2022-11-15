class AddTimestampToInstitution < ActiveRecord::Migration[6.1]
  def change
    add_timestamps :institutions, default: Time.zone.now
    change_column_default :institutions, :created_at, from: nil, to: nil
    change_column_default :institutions, :updated_at, from: nil, to: nil
  end
end
