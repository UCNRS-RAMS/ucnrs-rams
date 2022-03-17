class UserVisit < ApplicationRecord
  belongs_to :visit
  belongs_to :user
  belongs_to :institution

  def arrival_date
    arrives_at.to_date
  end

  def departure_date
    departs_at.to_date
  end
end
