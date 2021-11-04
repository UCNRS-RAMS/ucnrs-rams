class ReserveAddendum < ApplicationRecord
  validates :subject, presence: true
  validates :sort_order, presence: true

  belongs_to :reserve

  def self.in_sort_order
    order(:sort_order)
  end
end
