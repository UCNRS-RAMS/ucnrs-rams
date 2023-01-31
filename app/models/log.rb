class Log < ApplicationRecord
  belongs_to :record, polymorphic: true
  belongs_to :record_about, polymorphic: true, optional: true
  belongs_to :user

  ACTIONS = {
    submitted: "submitted",
    updated: "updated",
    created: "created",
    added: "added",
    sent: "sent",
    cancelled: "cancelled",
    deleted: "deleted",
  }.freeze
end
