class Waiver < ApplicationRecord
  validates :name, presence: true

  has_and_belongs_to_many :reserves

  def self.for_reserve(reserve)
    if reserve.present?
      left_joins(:reserves_waivers)
        .where(reserves_waivers: { reserve_id: reserve })
    else
      all
    end
  end
end
