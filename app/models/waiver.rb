class Waiver < ApplicationRecord
  validates :name, presence: true

  has_many :reserve_waivers, dependent: :destroy
  has_many :reserves, through: :reserve_waivers

  def self.for_reserve(reserve)
    if reserve.present?
      joins(:reserves)
        .where(reserves: { id: reserve })
    else
      all
    end
  end
end
