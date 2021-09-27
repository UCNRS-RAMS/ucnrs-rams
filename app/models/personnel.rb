class Personnel < Struct.new(:id, :name, :title, :phone, :email, :image)
  def self.fake
    [
      Personnel.new(1, "Suzanne Olyarnik", "Reserve Manager", "(707) 875-2020)", "email1@example.com", "personnel1.jpg"),
      Personnel.new(2, "Jacqueline Sones", "Research Coordinator", nil, "email2@example.com", "personnel2.jpg"),
      Personnel.new(3, "Luis Morales", "Reserve Steward", nil, "email3@example.com", "personnel3.jpg"),
    ]
  end
end
