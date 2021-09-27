class PersonnelPresenter
  def initialize(personnel)
    @personnel = personnel
  end

  attr_reader :personnel

  delegate :id, 
    :name,
    :title,
    :email,
    :image, 
    to: :personnel

  def phone
    personnel.phone if personnel.phone.present?
  end
end
