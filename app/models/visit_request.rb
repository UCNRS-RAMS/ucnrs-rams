class VisitRequest < Struct.new(:id, :status, :start_date, :end_date, :name)
  def self.fake
    [
      VisitRequest.new(1, :denied, Date.new(2020, 10, 1), Date.new(2020, 10, 10), "Bodega Marine Laboratory"),
      VisitRequest.new(2, :review, Date.new(2020, 5, 8), Date.new(2020, 5, 8), "Sedgwick Reserve"),
      VisitRequest.new(3, :approved, Date.new(2020, 4, 20), Date.new(2020, 4, 22), "James San Jacinto Mountains Reserve"),
      VisitRequest.new(4, :approved, Date.new(2020, 1, 9), Date.new(2020, 1, 13), "Merced Vernal Pools and Grassland Reserve"),
      VisitRequest.new(5, :approved, Date.new(2020, 12, 24), Date.new(2021, 1, 2), "Sedgwick Reserve"),
    ]
  end
end
