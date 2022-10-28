class ReservePersonnel < ApplicationRecord
  has_one_attached :avatar

  validates :user, presence: true
  validates :user, uniqueness: { scope: :reserve_id }
  validates :reserve, presence: true
  validates :receive_new_visit_email, inclusion: [true, false]
  validates :receive_incomplete_visit_email, inclusion: [true, false]
  validates :receive_update_email, inclusion: [true, false]
  validates :receive_approval_email, inclusion: [true, false]
  validates :receive_iacuc_email, inclusion: [true, false]
  validates :receive_drone_email, inclusion: [true, false]
  validates :receive_scuba_email, inclusion: [true, false]

  belongs_to :reserve
  belongs_to :user

  def self.receiving_new_visit_email
    where(receive_new_visit_email: true)
  end
end
