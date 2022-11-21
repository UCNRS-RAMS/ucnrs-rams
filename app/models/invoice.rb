class Invoice < ApplicationRecord
  has_many :invoice_recipients, dependent: :destroy
  has_many :users, through: :invoice_recipients
  has_many :invoice_payments, dependent: :destroy
  has_many :amenity_visits, dependent: :nullify
  belongs_to :visit
  has_many :invoice_payments

  FakeInvoice = Struct.new(:id, :status, :name, :amount)
  
  def self.fake
    [
      FakeInvoice.new(1, :due, "Bodega Marine Laboratory", 123456),
      FakeInvoice.new(2, :due, "Bodega Marine Laboratory", 310013),
      FakeInvoice.new(3, :paid, "Sedgwick Reserve", 100012),
    ]
  end

  def updated_balance
    self.balance_due = invoice_total - payments_amount_total
    self.save!
  end

  private

  def payments_amount_total
    self.invoice_payments.sum(&:amount)
  end

  def invoice_total
    self.amenity_visits.sum(&:subtotal)
  end
end
