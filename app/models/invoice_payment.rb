class InvoicePayment < ApplicationRecord
  belongs_to :user
  belongs_to :invoice
  has_many :logs, as: :record_about

  validates :amount, :paid_on, presence: true
end
