class ReservesIndexPresenter
  def initialize(search_filter: nil, categories: nil)
    @search_filter = search_filter
    @categories = categories
  end

  attr_reader :search_filter, :categories

  def reserves
    reserve_scope.map do |reserve|
      ReservePresenter.new(reserve)
    end
  end

  def reserve_tags
    ReserveTag.categories.keys
  end

  def amenities_tags
    ["amenity01", "amenity01", "amenity01", "amenity01", "amenity01", "amenity01", "amenity01", "amenity01"]
  end

  private

  def reserve_scope
    Reserve
      .searching_term(search_filter)
      .with_category(categories)
      .alphabetized
  end
end
