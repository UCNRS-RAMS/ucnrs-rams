class AmenityRateCategory < ApplicationRecord
  belongs_to :reserve

  validates :sort_order, uniqueness: { scope: :visible }
  validates :description, presence: true
  validates :visible, inclusion: [true, false]
  validates :state_university, inclusion: [true, false]
  validates :state_college, inclusion: [true, false]
  validates :community_college, inclusion: [true, false]
  validates :other_state_institution, inclusion: [true, false]
  validates :outside_state, inclusion: [true, false]
  validates :international, inclusion: [true, false]
  validates :K12, inclusion: [true, false]
  validates :nongovernmental, inclusion: [true, false]
  validates :governmental, inclusion: [true, false]
  validates :business, inclusion: [true, false]
  validates :other, inclusion: [true, false]

  def self.for_reserve(reserve)
    where(reserve: reserve)
  end

  def self.in_sort_order
    order(:sort_order)
  end

  def self.sort_by_visible
    order(visible: :desc)
  end
end
