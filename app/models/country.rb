class Country < ApplicationRecord
  validates :name, presence: true

  has_many :states
  has_many :institutions
  has_many :user_address_countries, class_name: "User", foreign_key: :address_country_id
  has_many :user_billing_address_countries, class_name: "User", foreign_key: :billing_address_country_id

  def self.alphabetical_by_name
    order(:name)
  end

  def has_states?
    states.exists?
  end
end
