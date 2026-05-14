class Country < ApplicationRecord
  validates :name, presence: true

  has_many :states, dependent: :destroy
  has_many :institutions, dependent: :destroy
  has_many :user_address_countries,
    class_name: "User",
    foreign_key: :address_country_id,
    inverse_of: :address_country,
    dependent: :restrict_with_error
  has_many :user_billing_address_countries,
    class_name: "User",
    foreign_key: :billing_address_country_id,
    inverse_of: :billing_address_country,
    dependent: :restrict_with_error

  def self.coded(code)
    find_by(code: code)
  end

  def self.alphabetical_by_name
    order(:name)
  end

  def has_states?
    states.exists?
  end
end
