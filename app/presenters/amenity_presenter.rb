class AmenityPresenter
  def initialize(amenity)
    @amenity = amenity
  end

  attr_reader :amenity

  delegate :id, to: :amenity

  def title
    amenity.description
  end
end
