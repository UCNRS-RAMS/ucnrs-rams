class Reserve < ApplicationRecord
  def self.alphabetized
    order(:pulldown_name)
  end

  has_many :amenities
end
