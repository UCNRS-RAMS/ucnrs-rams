class ReservesIndexPresenter
  def initialize(reserves = nil)
    @reserves = reserves || Reserve.alphabetized
  end

  def reserves
    @reserves.map do |reserve|
      ReservePresenter.new(reserve)
    end
  end

  def tags
    ["tag01", "tag01", "tag01", "tag01", "tag01", "tag01", "tag01", "tag01", "tag01"]
  end

  def amenities_tags
    ["amenity01", "amenity01", "amenity01", "amenity01", "amenity01", "amenity01", "amenity01", "amenity01"]
  end
end
