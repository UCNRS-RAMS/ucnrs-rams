class Visit < ApplicationRecord
  belongs_to :user
  belongs_to :project
  belongs_to :reserve

  def self.recent_start_date_first
    order(start_date: :desc)
  end
end
