class ReserveWaiver < ApplicationRecord
  self.table_name = "reserves_waivers"

  belongs_to :reserve
  belongs_to :waiver

  validates :reserve_id, uniqueness: { scope: :waiver_id }
end

