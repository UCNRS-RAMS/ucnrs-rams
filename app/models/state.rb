class State < ApplicationRecord
  validates :name, presence: true
  validates :country, presence: true

  belongs_to :country
  has_many :institutions, inverse_of: :state, dependent: :nullify
  has_many :user_address_states, class_name: "User", foreign_key: :address_state_id
  has_many :user_billing_address_states, class_name: "User", foreign_key: :billing_address_state_id

  def self.coded(code)
    find_by(code: code)
  end

  def self.alphabetical_by_name
    order(:name)
  end

  def self.in_country(country)
    where(country: country)
  end

  def in_country?(country)
    self.country == country
  end

  def self.blank
    State.new(id: nil, name: "")
  end
end
