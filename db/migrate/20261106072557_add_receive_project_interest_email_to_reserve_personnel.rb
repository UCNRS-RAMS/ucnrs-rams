# frozen_string_literal: true

class AddReceiveProjectInterestEmailToReservePersonnel < ActiveRecord::Migration[8.1]
  def change
    add_column :reserve_personnel, :receive_project_interest_email, :boolean, default: false, null: false
  end
end
