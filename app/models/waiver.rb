class Waiver < ApplicationRecord
  has_and_belongs_to_many :reserves
end
