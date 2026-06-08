class ReserveAddendum < ApplicationRecord
  validates :name, presence: true
  # rubocop:disable Rails/UniqueValidationWithoutIndex
  validates :sort_order, uniqueness: { scope: [:reserve_id] }
  # rubocop:enable Rails/UniqueValidationWithoutIndex

  belongs_to :reserve

  has_rich_text :content

  def self.in_sort_order
    order(:sort_order)
  end
end
