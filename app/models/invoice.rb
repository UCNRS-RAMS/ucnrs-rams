class Invoice < Struct.new(:id, :status, :name, :amount)
  def self.fake
    [
      Invoice.new(1, :due, "Bodega Marine Laboratory", 123456),
      Invoice.new(2, :due, "Bodega Marine Laboratory", 310013),
      Invoice.new(3, :paid, "Sedgwick Reserve", 100012),
    ]
  end
end
