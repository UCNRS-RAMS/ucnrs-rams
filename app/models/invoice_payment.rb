class InvoicePayment < ApplicationRecord
  belongs_to :user
  belongs_to :invoice

  validates :amount, :paid_on, presence: true
end
