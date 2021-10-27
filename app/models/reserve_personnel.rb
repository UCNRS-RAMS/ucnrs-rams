class ReservePersonnel < ApplicationRecord
  has_one_attached :avatar

  validates :user, presence: true
  validates :user, uniqueness: { scope: :reserve_id }
  validates :reserve, presence: true

  belongs_to :reserve
  belongs_to :user
end
