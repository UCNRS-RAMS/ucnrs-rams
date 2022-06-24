class Log < ApplicationRecord
  belongs_to :record, polymorphic: true
  belongs_to :user, optional: true
end
