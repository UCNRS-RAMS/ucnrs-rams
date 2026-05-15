class ReservePresenter
  def initialize(reserve)
    @reserve = reserve
  end

  attr_reader :reserve

  delegate_missing_to :reserve

  delegate :name, to: :billing_address_state, prefix: true

  def address_line_3
    "#{address_city}, #{state} #{address_postal_code}".squish
  end

  def state
    address_state&.name
  end

  def country
    address_country&.name
  end

  def billing_address_line_3
    "#{billing_city}, #{billing_state_name} #{billing_address_postal_code}".squish
  end

  def billing_state_name
    billing_address_state&.name
  end

  def billing_address_country_name
    billing_address_country&.name
  end

  def full_address_line
    [].tap do |address|
      address << address_line_1
      address << address_line_2 if address_line_2.present?
      address << address_line_3
    end.join("\n")
  end

  def full_billing_address_line
    [].tap do |address|
      address << billing_address_line_1
      address << billing_address_line_2 if billing_address_line_2.present?
      address << billing_address_line_3
      address << billing_address_country_name
    end.join("\n")
  end
end
