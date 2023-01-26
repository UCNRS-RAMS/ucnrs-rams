class ReservePersonnel < ApplicationRecord
  AVATAR_PLACEHOLDER = "personnel_avatar_placeholder.png".freeze

  mount_uploader :avatar, PersonnelUploader
  has_one_attached :avatar_old

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

  def self.role(user)
    find_by(user_id: user)&.role
  end

  def avatar_src
    avatar_url(:medium) || AVATAR_PLACEHOLDER
  end
end
