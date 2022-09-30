class Visits::AmenitiesPresenter
  def initialize(reserve_id: nil, user: nil)
    @reserve_id = reserve_id
    @user = user
  end

  attr_reader :user

  delegate :institution_name, to: :user

  def amenities_by_group_label
    Amenity
      .where(reserve_id: @reserve_id)
      .includes([:reserve])
      .by_group_number
      .not_disable
      .map { |amenity| Visits::AmenityPresenter.new(amenity, user: @user) }
      .group_by(&:group_label)
  end
end
