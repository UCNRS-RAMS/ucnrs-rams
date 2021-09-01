class Country < ApplicationRecord
  validates :name, presence: true

  has_many :states
  has_many :user_address_countries, class_name: "User", foreign_key: :address_country_id
  has_many :user_billing_address_countries, class_name: "User", foreign_key: :billing_address_country_id
end
