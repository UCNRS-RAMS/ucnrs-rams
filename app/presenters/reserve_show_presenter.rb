class ReserveShowPresenter
  def initialize(reserve:, personnel:)
    @reserve = reserve
    @personnel = personnel
  end

  delegate :id,
    :name,
    :address_line_1,
    :address_line_2,
    :address_city,
    :address_postal_code,
    :State,
    :Country,
    :has_avatar?,
    :reserve_avatar,
    :image_placeholder,
    to: :reserve, prefix: true

  def personnel
    @personnel.map do |person|
      PersonnelPresenter.new(person)
    end
  end

  private

  def reserve
    ReservePresenter.new(@reserve)
  end
end
