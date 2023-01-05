class ReservesIndexPresenter
  def initialize(search_filter: nil, tag_types: nil)
    @search_filter = search_filter
    @tag_types = tag_types
  end

  attr_reader :search_filter, :tag_types

  def reserves
    reserve_scope.map do |reserve|
      ReservePresenter.new(reserve)
    end
  end

  def reserve_tags
    ReserveTag.tag_types.keys
  end

  def amenities_tags
    ["amenity01", "amenity01", "amenity01", "amenity01", "amenity01", "amenity01", "amenity01", "amenity01"]
  end

  private

  def reserve_scope
    Reserve
      .searching_term(search_filter)
      .with_tag_type(tag_types)
      .alphabetized
  end
end
