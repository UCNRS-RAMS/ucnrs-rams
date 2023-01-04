class ReservesIndexPresenter
  def initialize(search_filter, reserves = nil)
    @reserves = reserves || Reserve.alphabetized
    @search_filter = search_filter
  end

  attr_reader :search_filter

  def reserves
    reserve_scope.map do |reserve|
      ReservePresenter.new(reserve)
    end
  end

  def tags
    ["tag01", "tag01", "tag01", "tag01", "tag01", "tag01", "tag01", "tag01", "tag01"]
  end

  def amenities_tags
    ["amenity01", "amenity01", "amenity01", "amenity01", "amenity01", "amenity01", "amenity01", "amenity01"]
  end

  private

  def reserve_scope
    Reserve
    .searching_term(search_filter)
  end
end
