class ReserveNote < ApplicationRecord
  belongs_to :record, polymorphic: true
  belongs_to :user
  belongs_to :reserve
end
