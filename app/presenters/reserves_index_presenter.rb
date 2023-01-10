class ReservesIndexPresenter
  def initialize(reserves = nil, search_filter: nil, tag_types: nil, tag_names: nil)
    @reserves = reserves || Reserve.alphabetized
    @search_filter = search_filter
    @tag_types = tag_types
    @tag_names = tag_names
  end

  attr_reader :search_filter, :tag_types, :tag_names

  def reserves
    reserve_scope.map do |reserve|
      ReservePresenter.new(reserve)
    end
  end

  def reserve_tags
    ReserveTag
    .pluck(:name, :tag_type)
    .to_h
    .then do |reserve_tags| 
      reserve_tags
      .keys
      .group_by { |tag| reserve_tags[tag] }
    end
  end

  def amenities_tags
    ["amenity01", "amenity01", "amenity01", "amenity01", "amenity01", "amenity01", "amenity01", "amenity01"]
  end

  private

  def reserve_scope
    Reserve
      .searching_term(search_filter)
      .with_tag_type(tag_types, tag_names)
  end
end
