class Invoice < ApplicationRecord
  has_many :invoice_recipients
  has_many :users, through: :invoice_recipients
  has_many :amenity_visits
  belongs_to :visit

  FakeInvoice = Struct.new(:id, :status, :name, :amount)
  
  def self.fake
    [
      FakeInvoice.new(1, :due, "Bodega Marine Laboratory", 123456),
      FakeInvoice.new(2, :due, "Bodega Marine Laboratory", 310013),
      FakeInvoice.new(3, :paid, "Sedgwick Reserve", 100012),
    ]
  end
end
