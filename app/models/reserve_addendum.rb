class ReserveAddendum < ApplicationRecord
  validates :name, presence: true
  validates :sort_order, uniqueness: { scope: [:reserve_id] }

  belongs_to :reserve

  has_rich_text :content

  def self.in_sort_order
    order(:sort_order)
  end
end
