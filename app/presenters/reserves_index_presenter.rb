class ReservesIndexPresenter
  def initialize(reserves = nil, search_filter: nil, selected_tags: nil)
    @reserves = reserves || Reserve.alphabetized
    @search_filter = search_filter
    @selected_tags = selected_tags
  end

  attr_reader :search_filter, :selected_tags

  def reserves
    reserve_scope.map do |reserve|
      ReservePresenter.new(reserve)
    end
  end

  def reserve_tags
    ReserveTag
    .pluck(:name, :category)
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
      .with_names(selected_tags)
      .alphabetized
  end
end
